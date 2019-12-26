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
require "#{File.dirname(__FILE__)}/opaque_construction_abridged"
require "#{File.dirname(__FILE__)}/window_construction_abridged"
require "#{File.dirname(__FILE__)}/face"
require "#{File.dirname(__FILE__)}/shade"
require "#{File.dirname(__FILE__)}/aperture"
require "#{File.dirname(__FILE__)}/construction_set"
require "#{File.dirname(__FILE__)}/door"
require "#{File.dirname(__FILE__)}/energy_material_no_mass"
require "#{File.dirname(__FILE__)}/energy_material"
require "#{File.dirname(__FILE__)}/energy_window_material_blind"
require "#{File.dirname(__FILE__)}/energy_window_material_gas_custom"
require "#{File.dirname(__FILE__)}/energy_window_material_gas"
require "#{File.dirname(__FILE__)}/energy_window_material_gas_mixture"
require "#{File.dirname(__FILE__)}/energy_window_material_glazing"
require "#{File.dirname(__FILE__)}/energy_window_material_shade"
require "#{File.dirname(__FILE__)}/energy_window_material_simpleglazsys"
require "#{File.dirname(__FILE__)}/room"
require "#{File.dirname(__FILE__)}/shade"
require "#{File.dirname(__FILE__)}/shade_construction"
require "#{File.dirname(__FILE__)}/schedule_type_limit"
require "#{File.dirname(__FILE__)}/schedule_fixed_interval_abridged"
require "#{File.dirname(__FILE__)}/schedule_ruleset_abridged"
require "#{File.dirname(__FILE__)}/space_type"
require "#{File.dirname(__FILE__)}/setpoint_thermostat"
require "#{File.dirname(__FILE__)}/setpoint_humidistat"
require 'openstudio'

module Ladybug
  module EnergyModel
    class Model
      attr_reader :errors, :warnings

      # Read Ladybug Energy Model JSON from disk
      def self.read_from_disk(file)
        hash = nil
        File.open(File.join(file), 'r') do |f|
          hash = JSON.parse(f.read, symbolize_names: true)
        end
        Model.new(hash)
      end

      # Load ModelObject from symbolized hash
      def initialize(hash)
        # initialize class variable @@extension only once
        @@extension ||= Extension.new
        @@schema ||= @@extension.schema

        @hash = hash
        @type = @hash[:type]
        raise 'Unknown model type' if @type.nil?
        raise "Incorrect model type '#{@type}'" unless @type == 'Model'

      end

      # check if the model is valid
      def valid?
        return validation_errors.empty?
      end

      # return detailed model validation errors
      def validation_errors
        if Gem.loaded_specs.has_key?("json-schema")
          require 'json-schema'
          JSON::Validator.fully_validate(@@schema, @hash)
        end
      end
      
      # convert to openstudio model, clears errors and warnings
      def to_openstudio_model(openstudio_model = nil)
        @errors = []
        @warnings = []

        @openstudio_model = if openstudio_model
                              openstudio_model
                            else
                              OpenStudio::Model::Model.new
                            end

        create_openstudio_objects

        @openstudio_model
      end

      private

      # create openstudio objects in the openstudio model
      def create_openstudio_objects
        create_materials
        create_constructions
        create_construction_set
        create_global_construction_set
        create_schedule_type_limits
        create_schedules
        create_space_types
        create_rooms
        create_orphaned_shades
        create_orphaned_faces
        create_orphaned_apertures
        create_orphaned_doors
      end

      #add if statement in case rooms are empty 
      def create_materials
        @hash[:properties][:energy][:materials].each do |material|
          material_type = material[:type]

          case material_type
          when 'EnergyMaterial'
            material_object = EnergyMaterial.new(material)
          when 'EnergyMaterialNoMass'
            material_object = EnergyMaterialNoMass.new(material)
          when 'EnergyWindowMaterialGas'
            material_object = EnergyWindowMaterialGas.new(material)
          when 'EnergyWindowMaterialGasCustom'
            material_object = EnergyWindowMaterialGasCustom.new(material)
          when 'EnergyWindowMaterialSimpleGlazSys'
            material_object = EnergyWindowMaterialSimpleGlazSys.new(material)
          when 'EnergyWindowMaterialBlind'
            material_object = EnergyWindowMaterialBlind.new(material)
          when 'EnergyWindowMaterialGlazing'
            material_object = EnergyWindowMaterialGlazing.new(material)
          when 'EnergyWindowMaterialShade'
            material_object = EnergyWindowMaterialShade.new(material)
          else
            raise "Unknown material type #{material_type}"
          end
          material_object.to_openstudio(@openstudio_model)
        end
      end


      def create_constructions
        @hash[:properties][:energy][:constructions].each do |construction|
          name = construction[:name]
          construction_type = construction[:type]
          
          case construction_type
          when 'OpaqueConstructionAbridged'
            construction_object = OpaqueConstructionAbridged.new(construction)
          when 'WindowConstructionAbridged'
            construction_object = WindowConstructionAbridged.new(construction)
          when 'ShadeConstruction'
            construction_object = ShadeConstruction.new(construction)
          else
            raise "Unknown construction type #{construction_type}."
          end
          construction_object.to_openstudio(@openstudio_model)
        end
      end

      def create_construction_set
        if @hash[:properties][:energy][:construction_sets]
          @hash[:properties][:energy][:construction_sets].each do |construction_set|
          construction_set_object = ConstructionSetAbridged.new(construction_set)
          construction_set_object.to_openstudio(@openstudio_model)
          end
        end
      end

      def create_global_construction_set
        if @hash[:properties][:energy][:global_construction_set]
          construction_name = @hash[:properties][:energy][:global_construction_set]
          construction = @openstudio_model.getDefaultConstructionSetByName(construction_name)
          unless construction.empty?
            openstudio_construction = construction.get
          end
          @openstudio_model.getBuilding.setDefaultConstructionSet(openstudio_construction)
        end
      end

      def create_schedule_type_limits
        if @hash[:properties][:energy][:schedule_type_limits]
          @hash[:properties][:energy][:schedule_type_limits].each do |schedule_type_limit|
            schedule_type_limit_object = ScheduleTypeLimit.new(schedule_type_limit)
            schedule_type_limit_object.to_openstudio(@openstudio_model)
          end
        end
      end

      def create_schedules
        if @hash[:properties][:energy][:schedules]
          @hash[:properties][:energy][:schedules].each do |schedule|
            schedule_type = schedule[:type]

            case schedule_type
            when 'ScheduleRulesetAbridged'
              schedule_object = ScheduleRulesetAbridged.new(schedule)
            when 'ScheduleFixedIntervalAbridged'
              schedule_object = ScheduleFixedIntervalAbridged.new(schedule)
            else
              raise("Unknown schedule type #{schedule_type}.")
            end
            schedule_object.to_openstudio(@openstudio_model)
          
          end
        end
      end

      def create_space_types
        if @hash[:properties][:energy][:program_types]
          @hash[:properties][:energy][:program_types].each do |space_type|
            space_type_object = SpaceType.new(space_type)
            space_type_object.to_openstudio(@openstudio_model)
          end
        end
      end 

      def create_rooms
        if @hash[:rooms]
          #global hash
          $room_array_setpoint = [] 
          @hash[:rooms].each do |room|
          room_object = Room.new(room)
          openstudio_room = room_object.to_openstudio(@openstudio_model)
          
          if room[:properties][:energy][:program_type] && !room[:properties][:energy][:setpoint]
            #adding room to global hash if a programtype is assigned and no setpoints
            #are assigned. 
            $room_array_setpoint << room
            #checking whether global hash containing setpoints is non empty.
            if $programtype_array
              $programtype_array.each do |programtype|
              programtype_name = programtype[:name]
              #stores an aray containing all rooms whose programtype lies in the programtype_array
              if room_array = $room_array_setpoint.select {|h| h[:properties][:energy][:program_type] = programtype_name}
                room_array.each do |single_room|
                  #looping through all rooms in the array to get room name
                  room_name = single_room[:name]
                  room_get = @openstudio_model.getSpaceByName(room_name)
                  unless room_get.empty?
                    room_object_get = room_get.get
                  end
                  thermal_zone = room_object_get.thermalZone()
                  thermal_zone_object = thermal_zone.get
                  
                  #creating thermostat for the programtype setpoint
                  thermostat_object = SetpointThermostat.new(programtype[:setpoint])
                  openstudio_thermostat = thermostat_object.to_openstudio(@openstudio_model)
                  thermal_zone_object.setThermostatSetpointDualSetpoint(openstudio_thermostat)
                  
                  if programtype[:setpoint][:humidification_schedule] or programtype[:setpoint][:dehumidification_schedule]
                    humidistat_object = ZoneControlHumidistat.new(programtype[:setpoint])
                    openstudio_humidistat = humidistat_object.to_openstudio(@openstudio_model)
                    thermal_zone_object.setZoneControlHumidistat(openstudio_humidistat)
                  end
                end
              end
            end
            end
          end
        end
      end
      end
      
      def create_orphaned_shades
        if @hash[:orphaned_shades]
          shading_surface_group = OpenStudio::Model::ShadingSurfaceGroup.new(@openstudio_model)
          shading_surface_group.setShadingSurfaceType('Building')
          @hash[:orphaned_shades].each do |shade|
          shade_object = Shade.new(shade)
          openstudio_shade = shade_object.to_openstudio(@openstudio_model)
          openstudio_shade.setShadingSurfaceGroup(shading_surface_group)
          end
        end
      end

#TODO: create runlog for errors. 
      def create_orphaned_faces
        if @hash[:orphaned_faces]
          raise "Orphaned Faces are not translatable to OpenStudio."
        end
      end

      def create_orphaned_apertures
        if @hash[:orphaned_apertures]
          raise "Orphaned Apertures are not translatable to OpenStudio."
        end
      end
      
      def create_orphaned_doors
        if @hash[:orphaned_doors]
          raise "Orphaned Doors are not translatable to OpenStudio."
        end
      end

      # for now make parent a space, check if should be a zone?

        # add if statement and to_openstudio object
        # if air_wall
        # DLM: todo
        # end
      
    end # Model
  end # EnergyModel
end # Ladybug
