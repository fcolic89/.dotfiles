#!/usr/bin/env lua
-- Git status docs: https://git-scm.com/docs/git-status

local git_status = {
  branch = '',
  behind = 0,
  ahead = 0,
  conflicts = 0,
  staged = 0,
  changed = 0,
  deleted = 0,
  untracked = 0,
  stashed = 0,
}

function prompt_print()
  local promp_output = {
    branch = "%{$fg_bold[magenta]%}",
    behind = "%{↓%G%}",
    ahead = "%{↑%G%}",
    conflicts = "%{$fg[red]%}%{✖%G%}",
    staged = "%{$fg[red]%}%{●%G%}",
    changed = "%{$fg_bold[green]%}%{+%G%}",
    deleted = "%{$fg_bold[blue]%}%{-%G%}",
    untracked = "%{$fg[cyan]%}%{?%G%}",
    stashed = "%{$fg_bold[blue]%}%{⚑%G%}",
    reset = "%{$reset_color%}"
  }

  for key, value in pairs(git_status) do
    if value and value ~= 0 then
      promp_output[key] = promp_output[key] .. value .. promp_output.reset
    else
      promp_output[key] = ''
    end
  end

  print(
    promp_output.branch ..
    promp_output.behind ..
    promp_output.ahead ..
    promp_output.conflicts ..
    promp_output.staged ..
    promp_output.changed ..
    promp_output.deleted ..
    promp_output.untracked ..
    promp_output.stashed
  )
end

function long_print()
  for k, v in pairs(git_status) do
    print(k .. " " .. v)
  end
end

function short_print()
  print(
    git_status.branch .. " " ..
    git_status.behind .. " " ..
    git_status.ahead .. " " ..
    git_status.conflicts .. " " ..
    git_status.staged .. " " ..
    git_status.changed .. " " ..
    git_status.deleted .. " " ..
    git_status.untracked .. " " ..
    git_status.stashed
  )
end

function set_stash_count()
  stash_handle = io.popen('git stash list | grep "$(git rev-parse --abbrev-ref HEAD)" | wc -l')
  git_status.stashed = stash_handle:read("n")
  stash_handle:close()
end

function get_tag_or_ref()
  local tag_handle = io.popen("git describe --tags 2> /dev/null")
  local tag = tag_handle:read("*a")
  local tag_ok = tag_handle:close()

  if tag_ok and tag then
    return trim(tag)
  end

  local ref_handle = io.popen("git rev-parse --short HEAD")
  local ref = ref_handle:read("*a")
  ref_handle:close()

  return trim(ref) .. "..."
end

function trim(s)
  return s:match "^%s*(.*)":match "(.-)%s*$"
end

function set_branch_name(line)
  if line:find("Initial commit on") or line:find("No commits yet on") then
    git_status.branch = line:match("(%S+)%s*$")
  elseif line:find("no branch") then
    git_status.branch = get_tag_or_ref()
  else
    local name_start = 4
    local name_end = line:find("%.%.%.")
    if name_end then
      name_end = name_end - 1
    else
      name_end = #line
    end
    git_status.branch = line:sub(name_start, name_end)
  end
end

function set_tracking_info(line)
  local _, i = line:find("ahead")
  if i ~= nil then
    git_status.ahead = line:sub(i + 2, i + 2)
  end

  local _, j = line:find("behind")
  if j ~= nil then
    git_status.behind = line:sub(j + 2, j + 2)
  end
end

function gather_status_info()
  local status_handle = io.popen("git status --porcelain --branch")
  local status = status_handle:read("*a")

  for line in status:gmatch("[^\r\n]+") do
    local index_status = line:sub(1, 1)
    local working_tree_status = line:sub(2, 2)

    if working_tree_status == "#" and index_status == "#" then
      set_branch_name(line)
      set_tracking_info(line)
    end

    if index_status == "A" then
      git_status.staged = git_status.staged + 1
    elseif index_status == "U" then
      git_status.conflicts = git_status.conflicts + 1
    elseif working_tree_status == "M" then
      git_status.changed = git_status.changed + 1
    elseif working_tree_status == "D" then
      git_status.deleted = git_status.deleted + 1
    elseif working_tree_status == "?" and index_status == "?" then
      git_status.untracked = git_status.untracked + 1
    end
  end

  status_handle:close()
  set_stash_count()
end

gather_status_info()
if #arg == 0 then
  long_print()
end

for _, option in ipairs(arg) do
  if option == "--short" or option == "-s" then
    short_print()
  elseif option == "--prompt" or option == "-p" then
    prompt_print()
  else
    long_print()
  end
end
