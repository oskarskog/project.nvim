local git = require('project.git')
local path = require('plenary.path')

describe('git', function()

  it('recognizes failed commands', function()
    assert.equal(true, git.is_error('fatal: not a git repository (or any of the parent directories): .git'))
  end)

  it('gets the correct git root', function() 
  -- TODO Fix this for when /tmp is a symlink

    local project_path = path:new('/tmp/project_git_spec/project')
    local subdir_path = project_path:joinpath('subdir1'):joinpath('subdir2')

    subdir_path:mkdir({parents = true})

    os.execute("git init --quiet " .. project_path.filename)
    vim.fn.execute("cd " .. subdir_path.filename, "silent")

    local found_root = git.get_repo_root()

    subdir_path:rm({recursive = true})

    assert.equal(project_path.filename, found_root)
  end)
end)
