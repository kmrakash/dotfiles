import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.lang.reflect.Array;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;

/**
 * LeetCode-style test runner.
 *
 * <p>Reads tests/&lt;ClassName&gt;.txt, runs every static method whose name starts with "solve"
 * against each test case, and stops at the first failing case. See README.md.
 */
final class TestRunner {
  /** Pass as the second argument of run() when the answer may be returned in any order. */
  static final int ANY_ORDER = 1;

  private static final long TIME_LIMIT_MS = Long.getLong("timeLimit", 2000L);
  private static final int MAX_CAPTURED_BYTES = 8 * 1024;
  private static final int MAX_STDOUT_LINES = 30;
  private static final double EPSILON = 1e-5;

  /** The real console; System.out is redirected while a solution runs. */
  private static final PrintStream CONSOLE = System.out;

  private TestRunner() {}

  static void run(Class<?> problem) {
    run(problem, 0);
  }

  static void run(Class<?> problem, int flags) {
    int exitCode;
    try {
      exitCode = execute(problem, flags) ? 0 : 1;
    } catch (SetupError e) {
      CONSOLE.println("Error: " + e.getMessage());
      exitCode = 2;
    }
    CONSOLE.flush();
    System.exit(exitCode);
  }

  // ---------------------------------------------------------------- running

  private static boolean execute(Class<?> problem, int flags) {
    List<Method> methods = new ArrayList<>();
    for (Method m : problem.getDeclaredMethods()) {
      if (Modifier.isStatic(m.getModifiers()) && !m.isSynthetic() && m.getName().startsWith("solve")) {
        m.setAccessible(true);
        methods.add(m);
      }
    }
    if (methods.isEmpty()) {
      throw new SetupError(
          "no static method named solve... found in " + problem.getSimpleName() + ".java");
    }
    methods.sort(Comparator.comparing(Method::getName));

    Path file = Paths.get("tests", problem.getSimpleName() + ".txt");
    List<List<String>> cases = readCases(file);
    if (cases.isEmpty()) throw new SetupError("no test cases in " + file);

    Integer only = Integer.getInteger("test");
    if (only != null && (only < 1 || only > cases.size())) {
      throw new SetupError("test #" + only + " does not exist; " + file + " has " + cases.size());
    }

    boolean allPassed = true;
    for (Method m : methods) {
      String label = methods.size() > 1 ? "[" + m.getName() + "] " : "";
      allPassed &= runMethod(m, cases, flags, only, label, file);
    }
    return allPassed;
  }

  private static boolean runMethod(
      Method m, List<List<String>> cases, int flags, Integer only, String label, Path file) {
    Type[] paramTypes = m.getGenericParameterTypes();
    boolean inPlace = m.getReturnType() == void.class;
    if (inPlace && paramTypes.length == 0) {
      throw new SetupError(m.getName() + "() returns void and takes no arguments: nothing to check");
    }
    Type expectedType = inPlace ? paramTypes[0] : m.getGenericReturnType();
    boolean anyOrder = (flags & ANY_ORDER) != 0;

    for (int i = 0; i < cases.size(); i++) {
      int number = i + 1;
      if (only != null && only != number) continue;

      List<String> lines = cases.get(i);
      if (lines.size() != paramTypes.length + 1) {
        throw new SetupError(
            "test #" + number + " in " + file + " has " + lines.size() + " line(s), but "
                + m.getName() + " needs " + paramTypes.length
                + " input line(s) followed by 1 expected line");
      }

      Object[] args = new Object[paramTypes.length];
      for (int j = 0; j < args.length; j++) {
        args[j] = parseLine(lines.get(j), paramTypes[j], number, "input line " + (j + 1));
      }
      Object expected = parseLine(lines.get(args.length), expectedType, number, "expected line");

      Outcome outcome = invoke(m, args);

      String problemText = null;
      if (outcome.timedOut) {
        problemText = "got:      Time Limit Exceeded (> " + TIME_LIMIT_MS + " ms)";
      } else if (outcome.error != null) {
        problemText = "got:      " + describe(outcome.error, m.getDeclaringClass());
      } else {
        Object actual = inPlace ? args[0] : outcome.value;
        if (!same(normalize(expected, anyOrder), normalize(actual, anyOrder))) {
          problemText = "got:      " + format(normalize(actual, false));
        }
      }

      if (problemText != null) {
        printFailure(label, number, m, lines, problemText, outcome.stdout);
        // A timed-out solution is still running; leave now so it cannot keep printing.
        if (outcome.timedOut) {
          CONSOLE.flush();
          System.exit(1);
        }
        return false;
      }
    }

    int total = cases.size();
    CONSOLE.println(
        label + (only != null ? "Test #" + only + " passed" : "Passed (" + total + "/" + total + ")"));
    return true;
  }

  private static void printFailure(
      String label, int number, Method m, List<String> lines, String problemText, String stdout) {
    CONSOLE.println(label + "Test #" + number + " failed");
    java.lang.reflect.Parameter[] params = m.getParameters();
    for (int j = 0; j < params.length; j++) {
      String name = params[j].isNamePresent() ? params[j].getName() + " = " : "";
      CONSOLE.println((j == 0 ? "  input:    " : "            ") + name + lines.get(j));
    }
    CONSOLE.println("  expected: " + lines.get(params.length));
    CONSOLE.println("  " + problemText);
    if (!stdout.isEmpty()) {
      String[] out = stdout.split("\n");
      for (int j = 0; j < out.length && j < MAX_STDOUT_LINES; j++) {
        CONSOLE.println((j == 0 ? "  stdout:   " : "            ") + out[j]);
      }
      if (out.length > MAX_STDOUT_LINES) {
        CONSOLE.println("            ... (" + (out.length - MAX_STDOUT_LINES) + " more lines)");
      }
    }
  }

  private static final class Outcome {
    volatile Object value;
    volatile Throwable error;
    boolean timedOut;
    String stdout = "";
  }

  private static Outcome invoke(Method m, Object[] args) {
    Outcome outcome = new Outcome();
    Thread worker =
        new Thread(
            () -> {
              try {
                outcome.value = m.invoke(null, args);
              } catch (InvocationTargetException e) {
                outcome.error = e.getCause();
              } catch (Throwable e) {
                outcome.error = e;
              }
            });
    worker.setDaemon(true);

    CappedBuffer buffer = new CappedBuffer();
    System.setOut(new PrintStream(buffer, true));
    try {
      worker.start();
      worker.join(TIME_LIMIT_MS);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
    outcome.timedOut = worker.isAlive();
    // If the solution is still running, keep its prints redirected until the runner exits.
    if (!outcome.timedOut) System.setOut(CONSOLE);
    outcome.stdout = buffer.text();
    return outcome;
  }

  /** Keeps the first few KB of what a solution prints, so a runaway loop cannot eat memory. */
  private static final class CappedBuffer extends OutputStream {
    private final byte[] data = new byte[MAX_CAPTURED_BYTES];
    private int size;
    private boolean truncated;

    @Override
    public synchronized void write(int b) {
      if (size < data.length) data[size++] = (byte) b;
      else truncated = true;
    }

    synchronized String text() {
      String s = new String(data, 0, size).stripTrailing();
      return truncated ? s + "\n... (output truncated)" : s;
    }
  }

  private static String describe(Throwable error, Class<?> problem) {
    StringBuilder sb = new StringBuilder(error.toString());
    for (StackTraceElement frame : error.getStackTrace()) {
      if (frame.getClassName().equals(problem.getName())) {
        sb.append(" at ").append(frame.getFileName()).append(':').append(frame.getLineNumber());
        break;
      }
    }
    return sb.toString();
  }

  // ---------------------------------------------------------------- test file

  private static List<List<String>> readCases(Path file) {
    List<String> lines;
    try {
      lines = Files.readAllLines(file);
    } catch (IOException e) {
      throw new SetupError("cannot read " + file + " (create it, one test case per block)");
    }
    List<List<String>> cases = new ArrayList<>();
    List<String> current = new ArrayList<>();
    for (String raw : lines) {
      String line = raw.trim();
      if (line.startsWith("#")) continue;
      if (line.isEmpty()) {
        if (!current.isEmpty()) cases.add(current);
        current = new ArrayList<>();
      } else {
        current.add(line);
      }
    }
    if (!current.isEmpty()) cases.add(current);
    return cases;
  }

  private static Object parseLine(String line, Type type, int testNumber, String what) {
    try {
      // A bare line for a String parameter is taken as-is; quotes are optional.
      if (type == String.class && !line.startsWith("\"")) return line;
      Parser parser = new Parser(line);
      Object raw = parser.value();
      parser.expectEnd();
      return convert(raw, type);
    } catch (ParseError e) {
      throw new SetupError(
          "test #" + testNumber + ", " + what + " `" + line + "`: " + e.getMessage());
    }
  }

  /** Parses `[1,[2,3],"x"]`-style text into nested Lists of String tokens (null for `null`). */
  private static final class Parser {
    private final String s;
    private int pos;

    Parser(String s) {
      this.s = s;
    }

    Object value() {
      skipSpaces();
      if (pos >= s.length()) throw new ParseError("value is missing");
      char c = s.charAt(pos);
      if (c == '[') return list();
      if (c == '"' || c == '\'') return quoted(c);
      int start = pos;
      while (pos < s.length() && s.charAt(pos) != ',' && s.charAt(pos) != ']') pos++;
      String token = s.substring(start, pos).trim();
      if (token.isEmpty()) throw new ParseError("value is missing at column " + (start + 1));
      return token.equals("null") ? null : token;
    }

    private List<Object> list() {
      List<Object> items = new ArrayList<>();
      pos++; // [
      skipSpaces();
      if (pos < s.length() && s.charAt(pos) == ']') {
        pos++;
        return items;
      }
      while (true) {
        items.add(value());
        skipSpaces();
        if (pos >= s.length()) throw new ParseError("missing closing ]");
        char c = s.charAt(pos++);
        if (c == ']') return items;
        if (c != ',') throw new ParseError("expected , or ] at column " + pos);
      }
    }

    private String quoted(char quote) {
      StringBuilder sb = new StringBuilder();
      pos++;
      while (pos < s.length() && s.charAt(pos) != quote) {
        if (s.charAt(pos) == '\\' && pos + 1 < s.length()) pos++;
        sb.append(s.charAt(pos++));
      }
      if (pos >= s.length()) throw new ParseError("missing closing quote");
      pos++;
      return sb.toString();
    }

    void expectEnd() {
      skipSpaces();
      if (pos < s.length()) throw new ParseError("unexpected text at column " + (pos + 1));
    }

    private void skipSpaces() {
      while (pos < s.length() && Character.isWhitespace(s.charAt(pos))) pos++;
    }
  }

  private static Object convert(Object raw, Type type) {
    if (type instanceof ParameterizedType) {
      ParameterizedType pt = (ParameterizedType) type;
      Type rawType = pt.getRawType();
      if (rawType == List.class || rawType == ArrayList.class || rawType == Collection.class) {
        if (raw == null) return null;
        Type elementType = pt.getActualTypeArguments()[0];
        List<Object> result = new ArrayList<>();
        for (Object item : asList(raw)) result.add(convert(item, elementType));
        return result;
      }
      throw new ParseError("unsupported type " + type.getTypeName());
    }
    if (!(type instanceof Class)) throw new ParseError("unsupported type " + type.getTypeName());

    Class<?> c = (Class<?>) type;
    if (c.isArray()) {
      if (raw == null) return null;
      List<?> items = asList(raw);
      Object array = Array.newInstance(c.getComponentType(), items.size());
      for (int i = 0; i < items.size(); i++) {
        Array.set(array, i, convert(items.get(i), c.getComponentType()));
      }
      return array;
    }
    if (c == Object.class) return raw;
    if (raw == null) {
      if (c.isPrimitive()) throw new ParseError("null is not allowed for " + c.getSimpleName());
      return null;
    }
    if (raw instanceof List) throw new ParseError("expected " + c.getSimpleName() + ", found a list");

    String token = (String) raw;
    try {
      if (c == int.class || c == Integer.class) return Integer.parseInt(token);
      if (c == long.class || c == Long.class) return Long.parseLong(token);
      if (c == double.class || c == Double.class) return Double.parseDouble(token);
    } catch (NumberFormatException e) {
      throw new ParseError("`" + token + "` is not a valid " + c.getSimpleName());
    }
    if (c == boolean.class || c == Boolean.class) {
      if (token.equals("true")) return true;
      if (token.equals("false")) return false;
      throw new ParseError("`" + token + "` is not true or false");
    }
    if (c == char.class || c == Character.class) {
      if (token.length() != 1) throw new ParseError("`" + token + "` is not a single character");
      return token.charAt(0);
    }
    if (c == String.class) return token;
    throw new ParseError("unsupported type " + c.getSimpleName());
  }

  private static List<?> asList(Object raw) {
    if (raw instanceof List) return (List<?>) raw;
    throw new ParseError("expected a list like [1,2,3], found `" + raw + "`");
  }

  // ---------------------------------------------------------------- comparing

  /** Turns arrays and collections into Lists so results can be compared and printed uniformly. */
  private static Object normalize(Object o, boolean anyOrder) {
    if (o == null) return null;
    List<Object> items;
    if (o.getClass().isArray()) {
      items = new ArrayList<>();
      for (int i = 0; i < Array.getLength(o); i++) items.add(normalize(Array.get(o, i), anyOrder));
    } else if (o instanceof Collection) {
      items = new ArrayList<>();
      for (Object item : (Collection<?>) o) items.add(normalize(item, anyOrder));
    } else {
      return o;
    }
    if (anyOrder) items.sort(Comparator.comparing(TestRunner::format));
    return items;
  }

  private static boolean same(Object a, Object b) {
    if (a == null || b == null) return a == b;
    if (a instanceof List && b instanceof List) {
      List<?> x = (List<?>) a;
      List<?> y = (List<?>) b;
      if (x.size() != y.size()) return false;
      for (int i = 0; i < x.size(); i++) {
        if (!same(x.get(i), y.get(i))) return false;
      }
      return true;
    }
    if (a instanceof Double && b instanceof Double) {
      double x = (Double) a;
      double y = (Double) b;
      return Double.compare(x, y) == 0 || Math.abs(x - y) <= EPSILON;
    }
    return a.equals(b);
  }

  private static String format(Object o) {
    if (o == null) return "null";
    if (o instanceof String || o instanceof Character) return "\"" + o + "\"";
    if (o instanceof List) {
      StringBuilder sb = new StringBuilder("[");
      for (Object item : (List<?>) o) {
        if (sb.length() > 1) sb.append(',');
        sb.append(format(item));
      }
      return sb.append(']').toString();
    }
    return String.valueOf(o);
  }

  // ---------------------------------------------------------------- errors

  /** Something is wrong with the test file or the solve signature, not with the answer. */
  private static final class SetupError extends RuntimeException {
    SetupError(String message) {
      super(message);
    }
  }

  private static final class ParseError extends RuntimeException {
    ParseError(String message) {
      super(message);
    }
  }
}
