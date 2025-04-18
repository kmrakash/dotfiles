_nvim-surround.txt_ A plugin for adding/deleting/changing delimiter pairs.

Author: Kyle Chui <https://www.github.com/kylechui>
License: MIT License

================================================================================
CONTENTS _nvim-surround.contents_

    1. Introduction ......................................... |nvim-surround|
    2. Usage .......................................... |nvim-surround.usage|
        2.1. The Basics .............................. |nvim-surround.basics|
        2.2. More Mappings .................... |nvim-surround.more_mappings|
        2.3. Default Pairs .................... |nvim-surround.default_pairs|
        2.4. Aliasing .............................. |nvim-surround.aliasing|
        2.5. Jumps .................................... |nvim-surround.jumps|
    3. Configuration .......................... |nvim-surround.configuration|
        3.1. Keymaps ......................... |nvim-surround.config.keymaps|
        3.2. Surrounds ..................... |nvim-surround.config.surrounds|
        3.3. Helper Functions ................ |nvim-surround.config.helpers|
        3.4. Aliases ......................... |nvim-surround.config.aliases|
        3.5. Highlights .................... |nvim-surround.config.highlight|
        3.6. Cursor ...................... |nvim-surround.config.move_cursor|
        3.7. Indentation ................ |nvim-surround.config.indent_lines|
    4. Resources .................................. |nvim-surround.resources|

================================================================================

1. Introduction _nvim-surround.introduction_

|nvim-surround| is a plugin for efficiently manipulating surrounding
left/right delimiter pairs, e.g. parentheses, quotes, HTML tags, and more.
This plugin provides keymaps for "adding" (through insert/normal/visual mode)
and "modifying" (deleting/changing) delimiter pairs.

================================================================================ 2. Usage _nvim-surround.usage_

|nvim-surround| has three main operations:

- Adding a delimiter pair to the buffer
- Deleting a delimiter pair from the buffer
- Changing a delimiter pair to a different pair

---

2.1. The Basics _nvim-surround.basics_

The primary way of adding a new pair to the buffer is via the normal-mode _ys_
operator, which stands for "you surround". It can be used via
`ys{motion}{char}`, which surrounds a given |motion| or |text-object| with a
delimiter pair associated with {char}. For example, `ysa")` means "you surround
around quotes with parentheses".

In all of the following examples, the `*` denotes the cursor position:

    Old text                    Command         New text ~
    local str = H*ello          ysiw"           local str = "Hello"
    require"nvim-surroun*d"     ysa")           require("nvim-surround")
    char c = *x;                ysl'            char c = 'x';
    int a[] = *32;              yst;}           int a[] = {32};

Furthermore, there are insert-mode _<C-g>s_ and visual-mode _S_ mappings, that
add the delimiter pair around the cursor and visual selection, respectively.
In all of the following examples, we will use `|` to demarcate the start and
end of a visual selection:

    Old text                    Command         New text ~
    local str = *               <C-g>s"         local str = "*"
    local tab = *               <C-g>s}         local str = {*}
    local str = |some text|     S'              local str = 'some text'
    |div id="test"|</div>       S>              <div id="test"></div>

To delete a delimiter pair, use the _ds_ operator, which stands for "delete
surround". It is used via `ds[char]`, deleting the surrounding pair associated
with {char}. For example, `ds)` means "delete surrounding parentheses".

    Old text                    Command         New text ~
    local x = ({ *32 })         ds)             local x = { 32 }
    See ':h h*elp'              ds'             See :h help
    local str = [[Hell*o]]      ds]             local str = [Hello]

To change a delimiter pair, use the _cs_ operator, which stands for "change
surround". It is used via `cs{target}{replacement}`, changing the surrounding
pair associated with {target} to a pair associated with {replacement}. For
example, `cs'"` means "change the surrounding single quotes to double quotes".

    Old text                    Command         New text ~
    '*some string'              cs'"            "some string"
    use<*"hello">               cs>)            use("hello")
    `some text*`                cs`}            {some text}

---

2.2. More Mappings _nvim-surround.more_mappings_

For each of the additive mappings, there are a few variants:

The _yss_ operator is a special case for |ys|, and operates on the current
line via `yss[char]`, ignoring leading and trailing whitespace. The _yS_ and
_ySS_ operators are analogous to |ys| and |yss|, but add the delimiter pair on
new lines.

    Old text                    Command         New text ~
    hel*lo world                yss"            "hello world"
    some content                ySStp           <p>
                                                some content
                                                </p>

The _<C-g>S_ insert-mode operator is analogous to |<C-g>s|, but adds the
delimiter pair on new lines.

    Old text                    Command         New text ~
    func_name*                  <C-g>S)         func_name(
                                                	*
                                                )

The _cS_ normal-mode operator is analogous to |cs|, but adds the replacement
delimiter pair on new lines.

    Old text                    Command         New text ~
    func(a*rgs)                 cS))            func(
                                                args
                                                )

For the visual-mode `S` map, the type of visual mode determines how the
delimiter pair is added

- |charwise-visual|: Adds the pair around the selection
- |linewise-visual|: Adds the pair around the selection, on new lines
- |blockwise-visual|: Adds the pair around the visual block, once per line

Note: For surrounds that add a delimiter pair on new lines, |nvim-surround|
re-indents the text inside the pair (which may be dependent on filetype!). For
example, the contents of an HTML tag pair may not be indented in a text file,
but might be in an HTML file. See |nvim-surround.config.indent_lines| for
details.

---

2.3. Default Pairs _nvim-surround.default_pairs_

We've looked at a few of the built-in surround actions, but here we'll go a
bit more in-depth. For all open/close pairs, e.g. `()`, adding a surround
using the closing character will surround the selection with just the pair
itself, whereas using the opening character will add a whitespace gap between
the selection and delimiter pair.

    Old text                    Command         New text ~
    *sample_text                ysiw}           {sample_text}
    *sample_text                ysiw{           { sample_text }

This applies for `()`, `{}`, `[]`, and `<>` pairs. When deleting or changing
open/close pairs, the closing character always leaves whitespace intact, while
the opening character will try to remove a whitespace character (if it
exists).

    Old text                    Command         New text ~
    {( sa*mple_text )}          ds(             {sample_text}
    {(sa*mple_text)}            ds(             {sample_text}
    {(sa*mple_text )}           ds(             {sample_text}
    {( sa*mple_text )}          ds)             { sample_text }

Note: Deleting with the opening character is possible when there is only
whitespace on one side, or even when it is missing altogether.

Changing surrounding pairs exhibits similar behaviors.

    Old text                    Command         New text ~
    (sa*mple_text)              cs)}            {sample_text}
    (sa*mple_text)              cs(}            {sample_text}
    (sa*mple_text)              cs((            ( sample_text )
    ( sa*mple_text )            cs()            (sample_text)

There are also a handful of built-in surrounds that are more complex. First up
we have HTML tags, which are triggered with either `t` or `T`. The user is
then queried for the tag type/attributes, after which they hit <CR> to create
the surrounding pair.

    Old text                    Command         New text ~
    div cont*ents               ysstdiv         <div>div contents</div>
    h1 *contents                yssth1 id="x"   <h1 id="x">h1 contents</h1>
    <div>d*iv contents</div>    dst             div contents
    <h1 id="head">t*ext</h1>    cstdiv          <div id="head">text</div>
    <h1 id="head">text*</h1>    csTdiv          <div>text</div>

The keys `t` and `T` are identical, except for the fact that `cst` will only
change the surrounding tag's type (leaving the attributes alone), while `csT`
will change the entirety of the surrounding tag's contents.

Note: When changing surrounding tags via `cst` or `csT`, a second replacement
character is unnecessary. See |nvim-surround.config.surrounds|.

Next are function calls, denoted by the key `f`. By default, they match a Lua
pattern consisting of some non-whitespace characters, followed by a balanced
pair of parentheses.

    Old text                    Command         New text ~
    arg*s                       ysiwffunc       func(args)
    f*unc_name(a, b, x)         dsf             a, b, x
    f*unc_name(a, b, x)         csfnew_name     new_name(a, b, x)

Note: Just like with HTML tags, a replacement character is unnecessary when
changing (via `csf`).

Finally, we have a "insert" key, denoted by `i`. It queries the user for what
should go on the left and right hand sides of a selection, and adds the
delimiter pair to the buffer. Currently, deletions and changes are not
supported.

    Old text                    Command         New text ~
    inner text                  yssi/<CR>\      /inner text\

---

2.4. Aliasing _nvim-surround.aliasing_

In |nvim-surround|, one can alias a character to "stand in for" one or more
other characters. If the alias is just a single character, then they can be
used interchangeably anywhere. For example, the default configuration aliases
`b` to represent `)` and `r` to represent `]`.

    Old text                    Command         New text ~
    sample* text                yssb            (sample text)
    [more stuff]                dsr             more stuff
    use["nvim*-surround"]       csrb            use("nvim-surround")

Note: While `ysabB` is a valid surround action, `ysarB` is not, since `ar` is
not a valid Vim motion. This can be side-stepped by creating the following
operator-mode maps:

> lua

    vim.keymap.set("o", "ir", "i[")
    vim.keymap.set("o", "ar", "a[")
    vim.keymap.set("o", "ia", "i<")
    vim.keymap.set("o", "aa", "a<")

<
The other type of alias is a "tabular alias", where each alias character
represents some set of characters. Tabular aliases are only used when
modifying existing delimiter pairs. For example, the default configuration
uses `q` as an alias for the set { ', ", ` }. Modifications with tabular
aliases modify the nearest such pair.

    Old text                    Command         New text ~
    "Nested '*quotes'"          dsq             "Nested quotes"
    "Nes*ted 'quotes'"          dsq             Nested 'quotes'
    "Nes*ted 'quotes'"          csqb            (Nested 'quotes')

Note: Tabular aliases cannot be used to add surrounding pairs, e.g. `ysa)q` is
invalid, since it's ambiguous which pair should be added.

---

2.5. Jumps _nvim-surround.jumps_

If the cursor is not located inside a surrounding pair, it can jump to the
"nearest" pair. When jumping, |nvim-surround| always prefers

- pairs that surround the cursor, before
- pairs that occur after the cursor, before
- pairs that occur before the cursor.

  Old text Command New text ~
  "hello"_ 'world' dsq "hello" world
  "hello" world_ csqB {hello} world
  *some "'nested' quotes" dsq some 'nested' quotes
  "'nested' quotes" t*ext dsq 'nested' quotes text

Note: |nvim-surround| jumps across lines to find the next/previous surrounding
pair, except for quote characters. This is done to match existing behavior for
the `a"` text-object.

================================================================================ 3. Configuration _nvim-surround.configuration_

To configure this plugin, call `require("nvim-surround").setup()` or
`require("nvim-surround").buffer_setup()`. The former configures "global"
options that are present in every buffer, while the latter configures
buffer-local options that override the global options. This is particularly
useful for setting up filetype-specific surrounds, i.e. by calling
`require("nvim-surround").buffer_setup()` in a `ftplugin/` file.

Both functions take a table as an argument, full of configuration options.

> lua

    require("nvim-surround").setup({
        keymaps =       -- Defines plugin keymaps
        surrounds =     -- Defines surround keys and behavior
        aliases =       -- Defines aliases
        highlight =     -- Defines highlight behavior
        move_cursor =   -- Defines cursor behavior
        indent_lines =  -- Defines line indentation behavior
    })

<

The main setup and buffer setup functions are strictly additive, so only the
keys that are to be modified need to be provided. To disable any default
behavior, set the corresponding value to `false`. For example, to disable
the `(` surround, call:

> lua

    require("nvim-surround").setup({
        surrounds = {
            ["("] = false,
        }
    })

## <

3.1. Keymaps _nvim-surround.config.keymaps_

The `keymaps` table defines the keymaps used to perform surround actions. The
general rule is that if the key ends in "\_line", the delimiter pair is added
on new lines. If the key ends in "\_cur", the surround is performed around the
current line.

The default configuration is as follows:

> lua

    keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yS",
        normal_cur_line = "ySS",
        visual = "S",
        visual_line = "gS",
        delete = "ds",
        change = "cs",
        change_line = "cS",
    },

<

Additionally, there is a corresponding set of |<Plug>| mappings that one may
use to set up their own custom keymaps:

> vim

    <Plug>(nvim-surround-insert)
    <Plug>(nvim-surround-insert-line)
    <Plug>(nvim-surround-normal)
    <Plug>(nvim-surround-normal-cur)
    <Plug>(nvim-surround-normal-line)
    <Plug>(nvim-surround-normal-cur-line)
    <Plug>(nvim-surround-visual)
    <Plug>(nvim-surround-visual-line)
    <Plug>(nvim-surround-delete)
    <Plug>(nvim-surround-change)
    <Plug>(nvim-surround-change-line)

## <

3.2. Surrounds _nvim-surround.config.surrounds_

The `surrounds` table associates each key with a "surround", which is a table
containing the following keys:

                                                    *nvim-surround.config.add*
    add: ~
        A function that returns the delimiter pair to be added to the buffer.
        For example, consider the function for adding parentheses:

> lua

        [")"] = {
            add = function()
                return { { "(" }, { ")" } }
            end,
        }

<
The function must return pairs of multi-line strings. Anything can be
called in the functions; consider the default for `f`:

> lua

        add = function()
            local config = require("nvim-surround.config")
            local result = config.get_input("Enter the function name: ")
            if result then
                return { { result .. "(" }, { ")" } }
            end
        end,

<
The user is queried for the function name, and that is used to create
the surrounding pair at runtime.

        For "static" delimiter pairs that are not evaluated at runtime, the
        function can be omitted and the `add` key can directly take on the
        value of the delimiter pair. Furthermore, tables with just one string
        can be replaced by the string itself. For example, the following
        configuration also adds parentheses:

> lua

        [")"] = {
            add = { "(", ")" },
        }

<
_nvim-surround.config.find_
find: ~
A function that returns the "parent selection" for a surrounding pair.
The selection returned should contain the surrounding pair and little
else, as it is used by the `delete` and `change` keys to determine
what to modify. For example, HTML tags are found via the `at`
text-object:

> lua

        ["t"] = {
            find = function()
                local config = require("nvim-surround.config")
                return config.get_selection({ motion = "at" })
            end,
        }

<
See |nvim-surround.config.get_selection()| for more information.

        For convenience, this key can also take a string as a value, which is
        then interpreted as a Lua pattern that represents the selection.

                                                 *nvim-surround.config.delete*
    delete: ~
        A function that returns the pair of selections to remove from the
        buffer when deleting the surrounding pair.

        For convenience, this key can also take a string as a value, which is
        then interpreted as a Lua pattern whose match groups represent the
        left/right delimiter pair. For example, function calls are deleted
        via

> lua

        delete = "^(.-%()().-(%))()$",

<
The Lua pattern matches the function name and opening parenthesis for
the left delimiter, and the closing parenthesis for the right
delimiter.

        See |nvim-surround.config.get_selections()| for more information.

                                                 *nvim-surround.config.change*
    change: ~
        A table of two keys: `target` and `replacement`.

        target: ~
            A function that returns the pair of selections to be replaced in
            the buffer when changing the surrounding pair. Similar to the
            `delete` key.

            For simplicity, this key can also take a string as a value, which
            is then interpreted as a Lua pattern whose match groups represent
            the left/right delimiter pair. For example, the default `T`
            surround's `change.target` key:

> lua

            target = "^<([^>]*)().-([^%/]*)()>$",

<
The Lua pattern matches the contents of the opening tag (including
attributes) for the left delimiter, and the contents of the
closing tag for the right delimiter.

            See |nvim-surround.config.get_selections()| for more information.

        replacement: ~
            A function that returns the surrounding pair to replace the target
            selections. This is kept separate from the `add` key because it is
            often the case that replacing a delimiter pair is slightly
            different from adding a new one. For example, when changing HTML
            tags you only want the inner contents to be changed, without
            including the angle brackets.

    Note: When the `change.replacement` key is provided, the user is not
    queried for a replacement character; the results of `change.replacement`
    are directly used as the replacement pair. For example, when changing HTML
    tag types, only `cst` is needed, instead of `cstt`.

There is a special key in the `surrounds` table, `invalid_key_behavior`, that
defines how |nvim-surround| behaves when a given key in the delimiter table is
omitted. It takes the same form as all other surrounds. The default behavior
is to treat the character literally, and add/modify the surrounding pair:

> lua

    invalid_key_behavior = {
        add = function(char)
            if not char or char:find("%c") then
                return nil
            end
            return { { char }, { char } }
        end,
        find = function(char)
            if not char or char:find("%c") then
                return nil
            end
            return M.get_selection({
                pattern = vim.pesc(char) .. ".-" .. vim.pesc(char),
            })
        end,
        delete = function(char)
            if not char or char:find("%c") then
                return nil
            end
            return M.get_selections({
                char = char,
                pattern = "^(.)().-(.)()$",
            })
        end,
    },

<
For example, `ysiw*` would surround a word with asterisks, and `ds*` would
delete those same asterisks, despite the `*` surround not being configured by
default. Note that control characters are valid inputs, with the exception of
<C-c>, which cancels the input (same as <Esc>).

---

3.3. Helper Functions _nvim-surround.config.helpers_

|nvim-surround| exposes a few helper functions to assist in finding
selection(s). For the sake of brevity we assume

> lua

    local config = require("nvim-surround.config")

<
_nvim-surround.config.get_input()_
config.get_input({prompt})
Queries the user for input using {prompt}. Properly handles keyboard
interrupts (i.e. <C-c>) and <Esc> for cancelling the input.

                                        *nvim-surround.config.get_selection()*

config.get_selection({args})
Retrieves a selection from the buffer using {args}. The {args} table
currently takes one of two keys:

    motion: ~
        A string that represents any Neovim motion. For example, the default
        `find` key for `(` is:

> lua

        find = function()
            return config.get_selection({ motion = "a(" })
        end,

<
pattern: ~
A Lua pattern to be found in the buffer. For example, the default
`find` key for `invalid_key_behavior` is:

> lua

        find = function(char)
            return config.get_selection({
                pattern = vim.pesc(char) .. ".-" .. vim.pesc(char),
            })
        end,

<
The Lua pattern escapes the provided character, and |nvim-surround|
finds a selection that starts and ends with that character.

    node: ~
        A Tree-sitter node type to be found in the buffer. For example, the
        default `find` key for `f` in Lua files is:

> lua

        find = function()
            return config.get_selection({ node = "function_call" })
        end,

<

                                       *nvim-surround.config.get_selections()*

config.get_selections({args})
Retrieves a pair of selections from the buffer using {args}. The {args}
table takes a {char} key and {pattern} key:

    char: ~
        The character associated with the current surround.
    pattern: ~
        A Lua pattern that narrows down a parent selection to the left/right
        pair to be modified. It must contain four match groups:

        * The left selection to be modified
        * An empty capture group
        * The right selection to be modified
        * An empty capture group

        Note: The empty capture groups must come immediately after the left
        and right selections.

        For example, the default `delete` key for `t` is:

> lua

        delete = function()
            return config.get_selections({
                char = "t",
                pattern = "^(%b<>)().-(%b<>)()$",
            })
        end,

<
The left selection to be deleted is a balanced pair of angle brackets
`%b<>`, immediately followed by an empty capture group. The right
selection is a second balanced pair of angle brackets `%b<>`, followed
by an empty capture group. Another example is the `change.target` key
for `t`:

> lua

        target = function()
            return config.get_selections({
                char = "t",
                pattern = "^<([^%s<>]*)().-([^/]*)()>$",
            })
        end,

<
The Lua pattern matches just the HTML tag type in both the beginning
and end.

---

3.4. Aliases _nvim-surround.config.aliases_

The aliases table maps characters to other characters, or lists of characters.
Its behavior is described in |nvim-surround.aliasing|. The default
configuration is

> lua

    aliases = {
        ["a"] = ">",
        ["b"] = ")",
        ["B"] = "}",
        ["r"] = "]",
        ["q"] = { '"', "'", "`" },
        ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
    },

<

---

3.5. Highlights _nvim-surround.config.highlight_

When adding a new delimiter pair to the buffer in normal mode, one can
optionally highlight the selection to be surrounded. Similarly, when changing
a surrounding pair, one can optionally highlight the pair to be replaced. The
`highlight` table takes the following keys:

    duration: ~
        The amount of time (in ms) to highlight the selection(s) before
        clearing them. If the value is zero, then the highlights persist
        until the surround action is completed.

The relevant highlight group is `NvimSurroundHighlight`, which can be
configured separately. The default highlight group used is `Visual`:

> vim

    highlight default link NvimSurroundHighlight Visual

## <

3.6. Cursor _nvim-surround.config.move_cursor_

By default (or when `move_cursor = "begin"`), when a surround action is
performed, the cursor moves to the beginning of the action.

    Old text                    Command         New text ~
    some_t*ext                  ysiw[           *[ some_text ]
    another { sample *}         ds{             another *sample
    (hello* world)              csbB            *{hello world}

If `move_cursor` is set to `"sticky"`, the cursor will "stick" to the current
character, and move with the text as the buffer changes.

    Old text                    Command         New text ~
    some_t*ext                  ysiw[           [ some_t*ext ]
    another { sample *}         ds{             another sampl*e
    (hello* world)              csbffoo<CR>     foo(hello* world)

If `move_cursor` is set to `false`, the cursor won't move at all, regardless
of how the buffer changes.

    Old text                    Command         New text ~
    some_t*ext                  ysiw[           [ some_*text ]
    another { *sample }         ds{             another sa*mple
    (hello* world)              csbffoo<CR>     foo(he*llo world)

---

3.7. Indentation _nvim-surround.config.indent_lines_

By default, when a surround action is performed, |nvim-surround| tries to
indent things "appropriately", i.e. when it is enabled by a Vim option. The
`indent_lines` key corresponds to a function with parameters {start} and
{stop}, which represent line numbers (inclusive). This indentation can be
disabled by setting `indent_lines = false` in one of the setup functions.

By default, |nvim-surround| uses the following function for indentation:

> lua

    indent_lines = function(start, stop)
        local b = vim.bo
        -- Only re-indent the selection if a formatter is set up already
        if start < stop
            and (b.equalprg ~= ""
            or b.indentexpr ~= ""
            or b.cindent
            or b.smartindent
            or b.lisp) then
            vim.cmd(string.format("silent normal! %dG=%dG", start, stop))
        end
    end,

# <

4. Resources _nvim-surround.resources_

Here are a few links to visit to get help/inspiration:

- Showcase: https://github.com/kylechui/nvim-surround/discussions/53
  - A place where people show off their configurations and custom surrounds
- Wiki: https://github.com/kylechui/nvim-surround/wiki
  - A repository of helpful information about |nvim-surround|

vim:tw=78:ts=8:ft=help:norl:conceallevel=0:
