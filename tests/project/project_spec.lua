local path = require('plenary.path')
local project = require('project')

describe('project', function()

  local root_path = path:new('/tmp/project_spec_tests')
  local projects_file_path = root_path:joinpath('projects_file.json')
  local base_dirs = {'a', 'b'}
  local projects = {'aa', 'bb'}

  before_each(function() 
    for _, base_dir in ipairs(base_dirs) do
      local base_dir_path = root_path:joinpath(base_dir)
      for _, project in ipairs(projects) do
        local project_dir_path = base_dir_path:joinpath(project)
        project_dir_path:mkdir({parents = true})
        os.execute("git init --quiet " .. project_dir_path.filename)
      end
    end
  end)

  after_each(function()
    root_path:rm({recursive = true})
  end)

  it('finds repo root', function() 
    
  end)

  describe('discovers', function()

    it('all projects in base dir', function() 
      local base_dirs = {{path = root_path.filename, max_depth = 3}}
      local projects = project.discover_projects(base_dirs)

      assert.equal(4, table.getn(projects))
      assert.equal(true, root_path:joinpath('a'):joinpath('aa'):exists())
      assert.equal(true, root_path:joinpath('a'):joinpath('bb'):exists())
      assert.equal(true, root_path:joinpath('b'):joinpath('aa'):exists())
      assert.equal(true, root_path:joinpath('b'):joinpath('bb'):exists())

    end)

    it('all projects in multiple base dirs', function() 
      local base_dirs = {
        {path = root_path:joinpath('a').filename, max_depth = 3},
        {path = root_path:joinpath('a').filename, max_depth = 3}
      }
      local projects = project.discover_projects(base_dirs)
      
      assert.equal(4, table.getn(projects))
      assert.equal(true, root_path:joinpath('a'):joinpath('aa'):exists())
      assert.equal(true, root_path:joinpath('a'):joinpath('bb'):exists())
      assert.equal(true, root_path:joinpath('b'):joinpath('aa'):exists())
      assert.equal(true, root_path:joinpath('b'):joinpath('bb'):exists())
    end)
  end)


end)
