local path = require('plenary.path')
local iter = require('plenary.iterators').iter
local utils = require('project.utils')

describe('utils', function()

  it('inits project table', function()
    local project_path = path:new('foo'):joinpath('bar'):joinpath('baz')
    local project = utils.init_project_from_path(project_path.filename)

    assert.equal('baz', project.title)
    assert.equal(project_path.filename, project.path)
    assert.equal(true, project.activated)
  end)

  it('finds the same projects as persisted', function()

    -- assert helper
    local assert_match = function(expected, actual)
      assert.equal(expected.path, actual.path)
      assert.equal(expected.title, actual.title)
      assert.equal(expected.activated, actual.activated)
    end

    -- set up some test data
    local root = path:new('p')
    local persisted_projects = iter({'a', 'b', 'c'})
      :map(function(n) 
        local project = utils.init_project_from_path(root:joinpath(n).filename)
        project.activated = false
        return project
      end):tolist()

    local discovered_projects = iter({'a', 'b', 'd'})
      :map(function(n)
        return utils.init_project_from_path(root:joinpath(n).filename)
      end):tolist()

    -- 
    local uniqed_projects = utils.uniq_projects(
      persisted_projects,
      discovered_projects
    )

    assert_match({path = 'p/a', title = 'a', activated = false}, uniqed_projects[1])
    assert_match({path = 'p/b', title = 'b', activated = false}, uniqed_projects[2])
    assert_match({path = 'p/c', title = 'c', activated = false}, uniqed_projects[3])
    assert_match({path = 'p/d', title = 'd', activated = true}, uniqed_projects[4])
  end)
end)
