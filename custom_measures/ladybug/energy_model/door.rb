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

require "#{File.dirname(__FILE__)}/model_object"



require 'openstudio'

module Ladybug
  module EnergyModel
    class Door < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash)
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'Door'
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getSubSurfaceByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end

      def create_openstudio_object(openstudio_model)
        openstudio_vertices = OpenStudio::Point3dVector.new
        @hash[:geometry][:boundary].each do |vertex|
          openstudio_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
        end

        if @hash[:properties][:energy][:construction]
          construction_name = @hash[:properties][:energy][:construction]
          construction = openstudio_model.getConstructionByName(construction_name)
          unless construction.empty?
            openstudio_construction = construction.get
          end
        end

        openstudio_subsurface = OpenStudio::Model::SubSurface.new(openstudio_vertices, openstudio_model)
        openstudio_subsurface.setName(@hash[:name])
        openstudio_subsurface.setConstruction(openstudio_construction) if openstudio_construction
        
        if @hash[:boundary_condition][:type] == 'Surface'
          openstudio_subsurface.setAdjacentSurface(@hash[:boundary_condition][:boundary_condition_objects][0])
        end

        if @hash[:is_glass] == false
          openstudio_subsurface.setSubSurfaceType('Door')
        else
          openstudio_subsurface.setSubSurfaceType('GlassDoor')
        end

        openstudio_subsurface
      end
    end # Door
  end # EnergyModel
end # Ladybug
