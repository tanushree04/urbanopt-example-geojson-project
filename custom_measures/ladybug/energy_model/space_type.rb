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

require "#{File.dirname(__FILE__)}/extension"
require "#{File.dirname(__FILE__)}/model_object"
require "#{File.dirname(__FILE__)}/people_abridged"
require "#{File.dirname(__FILE__)}/lighting_abridged"
require "#{File.dirname(__FILE__)}/electric_equipment_abridged"
require "#{File.dirname(__FILE__)}/gas_equipment_abridged"
require "#{File.dirname(__FILE__)}/infiltration_abridged"
require "#{File.dirname(__FILE__)}/ventilation_abridged"
require "#{File.dirname(__FILE__)}/setpoint_thermostat"
require "#{File.dirname(__FILE__)}/setpoint_humidistat"



require 'openstudio'

module Ladybug
  module EnergyModel
    class SpaceType < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
    
        raise "Incorrect model type '#{@type}'" unless @type == 'ProgramTypeAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        model_space_type = openstudio_model.getSpaceTypeByName(@hash[:name])
        return model_space_type.get unless model_space_type.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)    
        openstudio_space_type = OpenStudio::Model::SpaceType.new(openstudio_model)
        openstudio_space_type.setName(@hash[:name])

        if @hash[:people]
          people = PeopleAbridged.new(@hash[:people])
          openstudio_people = people.to_openstudio(openstudio_model)
          openstudio_people.setSpaceType(openstudio_space_type)
        end

        if @hash[:lighting]
          lights = LightingAbridged.new(@hash[:lighting])
          openstudio_lights = lights.to_openstudio(openstudio_model)
          openstudio_lights.setSpaceType(openstudio_space_type)
        end

        if @hash[:electric_equipment]
          electric_equipment = ElectricEquipmentAbridged.new(@hash[:electric_equipment])
          openstudio_electric_equipment = electric_equipment.to_openstudio(openstudio_model)
          openstudio_electric_equipment.setSpaceType(openstudio_space_type)
        end

        if @hash[:gas_equipment]
         gas_equipment = GasEquipmentAbridged.new(@hash[:gas_equipment])
         openstudio_gas_equipment = gas_equipment.to_openstudio(openstudio_model)
         openstudio_gas_equipment.setSpaceType(openstudio_space_type)
        end
         
        if @hash[:infiltration]
         infiltration = InfiltrationAbridged.new(@hash[:infiltration])
         openstudio_infiltration = infiltration.to_openstudio(openstudio_model)
         openstudio_infiltration.setSpaceType(openstudio_space_type)
        end
      
        if @hash[:ventilation]
         ventilation = VentilationAbridged.new(@hash[:ventilation])
         openstudio_ventilation = ventilation.to_openstudio(openstudio_model)
         openstudio_space_type.setDesignSpecificationOutdoorAir(openstudio_ventilation)
        end

        #Creating a global hash and adding setpoints from space types.
        if @hash[:setpoint]
          $programtype_array = []
          $programtype_array << @hash
        end

        openstudio_space_type
      end

    end #SpaceType 
  end #EnergyModel
end #Ladybug



