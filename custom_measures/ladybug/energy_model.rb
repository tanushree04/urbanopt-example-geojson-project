# *******************************************************************************
# Ladybug Tools Energy Model Schema, Copyright (c) 2019, Alliance for Sustainable
# Energy, LLC, Ladybug Tools LLC and other contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

puts "1HELLO = #{File.dirname(__FILE__)}"

require "#{File.dirname(__FILE__)}/energy_model/version"
require "#{File.dirname(__FILE__)}/energy_model/extension"
require "#{File.dirname(__FILE__)}/energy_model/extension_simulation_parameter"
require "#{File.dirname(__FILE__)}/energy_model/aperture"
require "#{File.dirname(__FILE__)}/energy_model/energy_material"
require "#{File.dirname(__FILE__)}/energy_model/energy_material_no_mass"
require "#{File.dirname(__FILE__)}/energy_model/energy_window_material_gas"
require "#{File.dirname(__FILE__)}/energy_model/energy_window_material_gas_mixture"
require "#{File.dirname(__FILE__)}/energy_model/energy_window_material_gas_custom"
require "#{File.dirname(__FILE__)}/energy_model/energy_window_material_blind"
require "#{File.dirname(__FILE__)}/energy_model/energy_window_material_glazing"
require "#{File.dirname(__FILE__)}/energy_model/energy_window_material_shade"
require "#{File.dirname(__FILE__)}/energy_model/energy_window_material_simpleglazsys"
require "#{File.dirname(__FILE__)}/energy_model/opaque_construction_abridged"
require "#{File.dirname(__FILE__)}/energy_model/window_construction_abridged"
require "#{File.dirname(__FILE__)}/energy_model/shade_construction"
require "#{File.dirname(__FILE__)}/energy_model/construction_set"
require "#{File.dirname(__FILE__)}/energy_model/face"
require "#{File.dirname(__FILE__)}/energy_model/model"
require "#{File.dirname(__FILE__)}/energy_model/model_object"
require "#{File.dirname(__FILE__)}/energy_model/room"
require "#{File.dirname(__FILE__)}/energy_model/aperture"
require "#{File.dirname(__FILE__)}/energy_model/door"
require "#{File.dirname(__FILE__)}/energy_model/shade"
require "#{File.dirname(__FILE__)}/energy_model/schedule_type_limit"
require "#{File.dirname(__FILE__)}/energy_model/schedule_fixed_interval_abridged"
require "#{File.dirname(__FILE__)}/energy_model/schedule_ruleset_abridged"
require "#{File.dirname(__FILE__)}/energy_model/space_type"
require "#{File.dirname(__FILE__)}/energy_model/people_abridged"
require "#{File.dirname(__FILE__)}/energy_model/lighting_abridged"
require "#{File.dirname(__FILE__)}/energy_model/electric_equipment_abridged"
require "#{File.dirname(__FILE__)}/energy_model/gas_equipment_abridged"
require "#{File.dirname(__FILE__)}/energy_model/infiltration_abridged"
require "#{File.dirname(__FILE__)}/energy_model/ventilation_abridged"
require "#{File.dirname(__FILE__)}/energy_model/setpoint_thermostat"
require "#{File.dirname(__FILE__)}/energy_model/setpoint_humidistat"
require "#{File.dirname(__FILE__)}/energy_model/ideal_air_system"
require "#{File.dirname(__FILE__)}/energy_model/simulation_parameter"