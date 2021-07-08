local _git = require('project.git')
local _utils = require('project.utils')

local iter = require('plenary.iterators').iter
local open = require('plenary.context_manager').open
local path = require('plenary.path')
local scan = require('plenary.scandir')
local with = require('plenary.context_manager').with

local M = {}

--- M.projects_file
-- File for persisting projects
M.projects_file = path:new(vim.fn.stdpath('data')):joinpath('projects.json').filename

--- M.root_markers
-- Root markers for projects
M.root_markers = vim.tbl_flatten({
  -- TODO: Add more root_markers
  _git.root_markers
})

--- M.get_root
-- Returns the root directory path of the current project or nil we're not in a project
M.get_root = function()
  -- TODO: figure out how to do this with multiple vcs
  return _git.get_repo_root()
end

--- M.read_projects
-- Reads projects from projects_file
M.read_projects = function()
  if not path:new(M.projets_file):exists() then
    return {}
  end
  return with(open(M.projects_file, 'r'), function(f)
    local projects = vim.fn.json_decode(f:read())
    return iter(projects)
      :filter(function(p) return p.activated end)
      :tolist()
  end)
end

--- M.write_projects
-- Writes projects to projects_file
-- @param projects: list of projects to persist
--   project.title (string):          visible name
--   project.path (string):           project root path
--   project.activated (boolean):     whether the project is active or not
M.write_projects = function(projects)
  with(open(M.projects_file, 'w'), function(f)
    return f:write(vim.fn.json_encode(projects))
  end)
end

--- M.add_projects
-- Adds projects to the projects file
-- @param projects: list of projects to persist
--   project.title (string):          visible name
--   project.path (string):           project root path
--   project.activated (boolean):     whether the project is active or not
M.add_projects = function(projects)
  local persisted_projects = M.read_projects()
  local uniqed_projects = _utils.uniq_projects(persisted_projects, projects)
  M.write_projects(uniqed_projects)
end

--- M.delete_project
-- Deletes a project
-- @param project_paths (string list): list of project paths
M.delete_projects = function(project_paths) 
  local projects = M.read_projects()
  for _, project in ipairs(projects) do
    if iter(project_paths):find(function(p) return p == project.path end) then
      project.acitvated = false
    end
  end
  M.write_projects(projects)
end

--- M.discover_projects
-- Discovers projects from base_dirs
-- @param base_dirs: list of base directory search configs
--   base_dir.path (string):        base directory path
--   base_dir.max_depth (number):   max depth for search 
M.discover_projects = function(base_dirs)

  local regexified_root_markers = iter(M.root_markers)
    :map(function(marker) return '%' .. marker .. '$' end)
    :tolist()

  return iter(base_dirs)
    :map(function(base_dir)
      local git_dirs = scan.scan_dir(vim.fn.expand(base_dir.path), {
        depth = base_dir.max_depth,
        add_dirs = true,
        hidden = true,
        search_pattern = regexified_root_markers
      })
      return iter(git_dirs):map(function(git_dir) 
        local project_path = path:new(git_dir):parent() 
        return _utils.init_project_from_path(project_path)
      end)
    end)
    :flatten()
    :tolist()
end

--- M.discover_and_write_projects
-- Discovers projects and persists new ones
-- @param base_dirs: list of base directory search configs
--   base_dir.path (string):        base directory path
--   base_dir.max_depth (number):   max depth for search 
M.discover_and_write_projects = function(base_dirs)
  local discovered_projects = M.discover_projects(base_dirs)
  M.add_projects(discovered_projects)
end

return M
