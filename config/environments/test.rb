# Copyright © Mapotempo, 2016
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
require 'active_support'
require 'tmpdir'

require './wrappers/demo'
require './wrappers/vroom'
require './wrappers/jsprit'
require './wrappers/ortools'

require './lib/cache_manager'
require './util/logger'

require 'byebug'
require 'pp'

module OptimizerWrapper
  TMP_DIR = File.join(Dir.tmpdir, 'optimizer-api', 'test', 'tmp')
  FileUtils.mkdir_p(TMP_DIR) unless File.directory?(TMP_DIR)
  @@tmp_vrp_dir = CacheManager.new(TMP_DIR)

  HEURISTICS = %w[path_cheapest_arc global_cheapest_arc local_cheapest_insertion savings parallel_cheapest_insertion first_unbound christofides].freeze
  DEMO = Wrappers::Demo.new(tmp_dir: TMP_DIR)
  VROOM = Wrappers::Vroom.new(tmp_dir: TMP_DIR)
  JSPRIT = Wrappers::Jsprit.new(tmp_dir: TMP_DIR)
  # if dependencies don't exist (libprotobuf10 on debian) provide or-tools dependencies location
  ORTOOLS_EXEC = 'LD_LIBRARY_PATH=../or-tools/dependencies/install/lib/:../or-tools/lib/ ../optimizer-ortools/tsp_simple'.freeze
  ORTOOLS = Wrappers::Ortools.new(tmp_dir: TMP_DIR, exec_ortools: ORTOOLS_EXEC)

  PARAMS_LIMIT = { points: 150, vehicles: 10 }.freeze

  DUMP_DIR = File.join(Dir.tmpdir, 'optimizer-api', 'test', 'dump')
  FileUtils.mkdir_p(DUMP_DIR) unless File.directory?(DUMP_DIR)
  @@dump_vrp_dir = CacheManager.new(DUMP_DIR)

  OptimizerLogger.level = ENV['LOG_LEVEL']&.to_sym || :fatal
  OptimizerLogger.with_datetime = true
  # OptimizerLogger.caller_location = nil => nil is default

  I18n.available_locales = [:en, :fr]
  I18n.default_locale = :en

  @@c = {
    product_title: 'Optimizers API',
    product_contact_email: 'tech@mapotempo.com',
    product_contact_url: 'https://github.com/Mapotempo/optimizer-api',
    access_by_api_key: {
      file: './config/access.rb'
    },
    services: {
      demo: DEMO,
      vroom: VROOM,
      jsprit: JSPRIT,
      ortools: ORTOOLS,
    },
    profiles: {
      demo: {
        queue: 'DEFAULT',
        services: {
          vrp: [:demo, :vroom, :jsprit, :ortools]
        },
        params_limit: PARAMS_LIMIT
      },
      solvers: {
        queue: 'DEFAULT',
        services: {
          vrp: [:vroom, :ortools]
        },
        params_limit: PARAMS_LIMIT
      },
      vroom: {
        queue: 'DEFAULT',
        services: {
          vrp: [:vroom]
        },
        params_limit: PARAMS_LIMIT
      },
      ortools: {
        queue: 'DEFAULT',
        services: {
          vrp: [:ortools]
        },
        params_limit: PARAMS_LIMIT
      },
      jsprit: {
        queue: 'DEFAULT',
        services: {
          vrp: [:jsprit]
        },
        params_limit: PARAMS_LIMIT
      },
    },
    solve: {
      synchronously: ENV['OPTIM_SOLVE_SYNCHRONOUSLY'] ? ENV['OPTIM_SOLVE_SYNCHRONOUSLY'] == 'true' : true,
      repetition: ENV['OPTIM_CLUST_SCHED_REPETITION']&.to_i || 3
    },
    router: {
      api_key: ENV['ROUTER_API_KEY'] || 'demo',
      url: ENV['ROUTER_URL'] || 'http://localhost:4899/0.1'
    },
    dump: {
      vrp: ENV['OPTIM_DUMP_VRP'] ? ENV['OPTIM_DUMP_VRP'] == 'true' : false,
      solution: ENV['OPTIM_DUMP_SOLUTION'] ? ENV['OPTIM_DUMP_SOLUTION'] == 'true' : false
    },
    debug: {
      output_clusters: ENV['OPTIM_DBG_OUTPUT_CLUSTERS'] == 'true',
      output_schedule: ENV['OPTIM_DBG_OUTPUT_SCHEDULE'] == 'true',
      batch_heuristic: ENV['OPTIM_DBG_BATCH_HEURISTIC'] == 'true'
    }
  }
end
