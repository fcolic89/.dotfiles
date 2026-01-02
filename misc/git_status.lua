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

function promptPrint()
  local prompOutput = {
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
      prompOutput[key] = prompOutput[key] .. value .. prompOutput.reset
    else
      prompOutput[key] = ''
    end
  end

  print(
    prompOutput.branch ..
    prompOutput.behind ..
    prompOutput.ahead ..
    prompOutput.conflicts ..
    prompOutput.staged ..
    prompOutput.changed ..
    prompOutput.deleted ..
    prompOutput.untracked ..
    prompOutput.stashed
  )
end

function longPrint()
  for k, v in pairs(git_status) do
    print(k .. " " .. v)
  end
end

function shortPrint()
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

function setStashCount()
  stash_handle = io.popen('git stash list | grep "$(git rev-parse --abbrev-ref HEAD)" | wc -l')
  git_status.stashed = stash_handle:read("n")
  stash_handle:close()
end

function getTagOrRef()
  local tag_handle = io.popen("git describe --tags")
  local tag = tag_handle:read("*a")
  tag_handle:close()

  if tag then
    return tag
  else
    local ref_handle = io.popen("git rev-parse --short HEAD")
    local ref = ref_handle:read("*a")
    ref_handle:close()

    return ref
  end
end

function setBranchName(line)
  if line:find("Initial commit on") or line:find("No commits yet on") then
    git_status.branch = line:match("(%S+)%s*$")
  elseif line:find("no branch") then
    git_status.branch = getTagOrRef()
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

function setTrackingInfo(line)
  local _, i = line:find("ahead")
  if i ~= nil then
    git_status.ahead = line:sub(i + 2, i + 2)
  end

  local _, j = line:find("behind")
  if j ~= nil then
    git_status.behind = line:sub(j + 2, j + 2)
  end
end

function getStatus()
  local status_handle = io.popen("git status --porcelain --branch")
  local status = status_handle:read("*a")

  for line in status:gmatch("[^\r\n]+") do
    local index_status = line:sub(1, 1)
    local working_tree_status = line:sub(2, 2)

    if working_tree_status == "#" and index_status == "#" then
      setBranchName(line)
      setTrackingInfo(line)
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
  setStashCount()
end

getStatus()
if #arg == 0 then
  longPrint()
end

for _, option in ipairs(arg) do
  if option == "--short" or option == "-s" then
    shortPrint()
  elseif option == "--prompt" or option == "-p" then
    promptPrint()
  else
    longPrint()
  end
end
