## Basics

# Vim Motions

- Navigation each character

  - h -> a character left
  - j -> a character down
  - k -> a character up
  - l -> a character right
  - <C-d> -> Half screen down
  - <C-u> -> Half screen up
    \*Note : zz -> to move cursor into center of the screen
  - { -> Move blocks upward
  - } -> Move blocks downward

- Teleportation

  - m<character> -> Add marks
  - <leader>f' -> Show all marks
  - <C-o> -> teleport to next mark
  - <C-i> -> teleport to previous mark
  - gg -> move cursor to top the file
  - G -> move cursor to bottom of the file
  - % -> Jump between matching brackets
  - <C-z> -> Suspend vim sessions and fg to return back to same session
  - gx -> Open url under the cursor in default browser
  - gf -> Open file path under the cursor
  - <Number>G -> Move the cursor into the mentioned line number

- Better Escape and Quit

  - jj -> To escape insert mode and move to normal mode
  - ZZ -> to quit and save current buffer
  - ZQ -> to quit and remove unsaved changes from current buffer

- Folds

  - za -> toggle folds under the cursor
  - zi -> toggle folds across file

- Editing

  - i -> Insert mode left of the cursor
  - I -> Insert mode at the beginning of non-whitspace character
  - o -> Insert mode starts with new line below the cursor
  - O -> Insert mode starts with new line above the cursor
  - a -> Append text right of cursor
  - A -> Append at the end of the line
  - <C-v> -> Visual Block mode to add multiple cursor
  - J -> Move line below the cursor to the line at the cursor

- Toggle Case

  - ~ -> Toggle case under the cursor
  - g~ -> Toggle case with vim motions

- Indentation
  - gg=G -> Indent properly whole file
