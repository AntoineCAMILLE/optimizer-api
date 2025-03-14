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
ENV['APP_ENV'] ||= 'development'
require File.expand_path('../config/environments/' + ENV['APP_ENV'], __FILE__)

Dir[File.dirname(__FILE__) + '/config/initializers/*.rb'].sort.each { |file| require file }
Dir[File.dirname(__FILE__) + '/../models/*.rb'].sort.each { |file| require file }
require './optimizer_wrapper'
require './api/root'
