local M = {}

M.is_error = function(input) 
  local prefix = 'fatal:'
  return input:find(prefix, 1, #prefix) ~= nil
end

M.root_markers = {'.git'}

M.get_repo_root = function()
  local git_cmd = 'git -C ' .. vim.loop.cwd() .. ' rev-parse --show-toplevel'
  local git_root = vim.fn.systemlist(git_cmd)[1]
  if not git_root or M.is_error(git_root) then
    return nil
  end
  return git_root
end

return M
