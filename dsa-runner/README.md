# DSA Patterns: test setup

Write a solution, list test cases in a text file, run them all with one command.

## Daily use

```sh
./new.sh TwoSum        # creates TwoSum.java and tests/TwoSum.txt
./run.sh TwoSum        # runs every test case, stops at the first failure
./run.sh TwoSum 3      # runs only test #3
```

All tests passing prints:

```
Passed (5/5)
```

The first failing test prints:

```
Test #2 failed
  input:    nums = [2,3,1,2,4,3]
            target = 7
            maxElement = 4
  expected: 2
  got:      3
  stdout:   0 0
            0 1
```

`stdout` is whatever your solution printed during that test. Debug prints are
hidden for passing tests, so you can leave them in.

## Writing a problem

`new.sh` copies `Template.java`. The rules:

- The solution is a `static` method whose name starts with `solve`.
- It **returns** the answer (do not print it).
- `main` calls `TestRunner.run(YourClass.class)`.

```java
class TwoSum {
  static int[] solve(int[] nums, int target) {
    ...
  }

  public static void main(String[] args) {
    TestRunner.run(TwoSum.class);
  }
}
```

## Test file format

`tests/<ClassName>.txt`: one line per `solve` parameter, in order, then one
line with the expected answer. A blank line separates test cases. Lines
starting with `#` are comments.

```
[2,7,11,15]
9
[0,1]

[3,2,4]
6
[1,2]
```

## Supported types

Parameters and return values can be any of these:

| Type | Line in the test file |
|---|---|
| `int`, `long`, `double` | `42`, `9999999999`, `1.5` |
| `boolean` | `true` |
| `char` | `"a"` |
| `String` | `"hello"` or `hello` |
| `int[]`, `long[]`, `double[]`, `char[]`, `String[]` | `[1,2,3]`, `["a","b"]` |
| `int[][]`, `char[][]` (any depth) | `[[1,2],[3,4]]` |
| `List<Integer>`, `List<String>`, `List<List<Integer>>` (any nesting) | `[1,2,3]`, `[[1,2],[3]]` |

`double` results are compared with a tolerance of `1e-5`.

Not supported yet: linked lists, trees, and design problems (`LRUCache` style).

## Special cases

**Answer can be in any order** (3Sum, subsets):

```java
TestRunner.run(ThreeSum.class, TestRunner.ANY_ORDER);
```

**In-place problems:** make `solve` return `void`. The runner then compares
the first argument, after the call, with the expected line.

**Several approaches:** add `solve2`, `solveBruteForce`, and so on. Each one
runs against all tests and is reported separately:

```
[solve] Passed (5/5)
[solve2] Test #3 failed
```

**Infinite loops:** a test that runs longer than 2 seconds fails as
`Time Limit Exceeded`. To change the limit, edit the `java` line in `run.sh`
to add `-DtimeLimit=5000` (milliseconds).

**Exceptions:** reported as the failing test, with the line number in your file.

## Files

| File | Purpose |
|---|---|
| `TestRunner.java` | The runner. You should not need to edit it. |
| `Template.java` | Base for new problems; edit it to change what `new.sh` generates. |
| `new.sh`, `run.sh` | Create and run a problem. |
| `tests/` | One test file per problem. |
| `out/` | Compiled classes. Safe to delete. |

`run.sh` is needed because Java 17 cannot run `java TwoSum.java` when the file
uses a second source file (`TestRunner.java`).
