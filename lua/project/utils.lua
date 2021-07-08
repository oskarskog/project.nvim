local iter  = require('plenary.iterators').iter

local M = {}

--- M.init_project_from_path
-- Initializes a new project table given a path
-- @param project_path (string):    project's root path
M.init_project_from_path = function(project_path)
  return {
    path = project_path,
    title = project_path:match("[^/]+$"),
    activated = true
  }
end

-- M.uniq_projects
-- Performs a uniq by path operation, dropping projects from drop_projects
-- @param keep_projects: projects list
-- @param drop_projects: projects list to uniq and add to keep_projects
M.uniq_projects = function(keep_projects, drop_projects)
  local keep_project = function(project)
    return not iter(keep_projects):find(function(kp)
      return kp.path == project.path
    end)
  end
  local filtered_drop_projects = iter(drop_projects):filter(keep_project)
  return iter(keep_projects):chain(filtered_drop_projects):tolist()
end

return M
