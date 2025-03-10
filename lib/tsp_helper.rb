# Copyright © Mapotempo, 2018
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

module TSPHelper
  def self.create_tsp(vrp, vehicle)
    services = []
    vrp.points.each{ |pt|
      service = vrp.services.find{ |service_| service_.activity.point_id == pt.id }
      next if !service

      services << {
        id: service[:id],
        activity: {
          point_id: service.activity.point_id,
          duration: service.activity.duration
        }
      }
    }

    problem = {
      matrices: vrp.matrices,
      points: vrp.points.collect{ |pt|
        {
          id: pt.id,
          matrix_index: pt.matrix_index
        }
      },
      vehicles: [{
        id: vehicle.id,
        start_point_id: vehicle.start_point_id,
        matrix_id: vehicle.matrix_id
      }],
      services: services
    }

    Models::Vrp.create(problem)
  end

  def self.solve(tsp)
    vroom = OptimizerWrapper::VROOM
    progress = 0
    result = vroom.solve(tsp){
      progress += 1
    }
  end
end
