# Copyright (c) 2014 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
# Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require "yast"
require "smbtad/smbta_conf_reader"

module Smbtad
  class SmbtadDialog

   
    include Yast::UIShortcuts
    include Yast::I18n
    
    $parser = INIConfigParser.new
    $coha = $parser.get_conf_hash
    
#    $coha_old = $coha
    

#    @wd = {"LabelNetwork" => {"widget" => ":label_network", "label" => "Network Settings"},
#           "UDS" => {"widget" => :custom, "custom_widget" => Frame( "SMBTAD Network Configuration", Left(CheckBox(Id(":cb"), "TEST")))}                    
#          }

    def self.run
      Yast.import "UI"
      dialog = SmbtadDialog.new
      dialog.run
    end


    def run
      return unless create_dialog

      begin
        return controller_loop
      ensure
        close_dialog
      end
    end

  private
    DEFAULT_SIZE_OPT = Yast::Term.new(:opt, :defaultsize)

    def create_dialog
      Yast::UI.OpenDialog DEFAULT_SIZE_OPT, dialog_content
    end

    def close_dialog
      Yast::UI.CloseDialog
    end
    def tab_contents
      HBox(Label("TEST TEST BLUBB BLABB"))
    end

    def dialog_content
      tab_labels = [
                   Item(Id(:general_tab), _("&General Settings"), true),
                   Item(Id(:network_tab), _("&Network Settings")),
                   Item(Id(:database_tab), _("&Database Settings"))
                   ]
      VBox(
        headings,
        HBox(
            Left(DumbTab(Id(:tabs), tab_labels, ReplacePoint(Id(":tab_contents"), VBox(general_page()))))
            ),
                      
            Right(Bottom(HBox(save_button, generell_buttons)))
          )
    end
    
    def general_page
            VBox(VSpacing(0.5),
            Frame("General Settings", HBox( Empty(), 
            Left(HBox(HSquash(IntField(Id(:debug_level), "Debug Level", 0, 10, $coha['general']['debug_level'])), Empty(), HSpacing(3.0), 
            TimeField(Id(:interval), "Interval", $coha['maintenance']['interval'])
            )))))
    end

    def network_page
       VBox(VSpacing(0.5),
            Frame("Network Settings", HBox(
            CheckBox(Id(:cb), _("Unix Domain Socket?"), true),
            InputField(Id(:networkport), "Networkport:", $coha['network']['port_number'].to_s),
            InputField(Id(:queryport), "Queryport:", $coha['network']['query_port'].to_s)
           )))
           
    end

    def database_page

       if $coha['database']['driver'] == "pgsql"
         driver_items = [Item("pgsql", true), Item("mysql"), Item("sqlite3")]
       elsif $coha['database']['driver'] == "mysql"
         driver_items = [Item("pgsql"), Item("mysql", true), Item("sqlite3")]
       elsif $coha['database']['driver'] == "sqlite3"
         driver_items = [Item("pgsql"), Item("mysql"), Item("sqlite3", true)]
       end
       VBox(VSpacing(0.5),
            Frame("Database Settings", HBox(
            Empty(),
            InputField(Id(:dbuser),"User:", $coha['database']['user']),
            Password(Id(:password), "Password:", $coha['database']['password']),
            InputField(Id(:dbname),"Databasename:", $coha['database']['name']),
            InputField(Id(:host), "Host:", $coha['database']['host']),
            ComboBox(Id(:driver), "Select DB Driver", driver_items) 
            )))
            
           
    end

    def update_hash(ptab)

      if ptab.to_s == "database_tab"
        #database        
        $coha["database"]['user'] = Yast::UI.QueryWidget(Id(:dbuser), :Value).to_s
        $coha["database"]['password'] = Yast::UI.QueryWidget(Id(:password), :Value).to_s
        $coha["database"]['name'] = Yast::UI.QueryWidget(Id(:dbname), :Value).to_s
        $coha["database"]['host'] = Yast::UI.QueryWidget(Id(:host), :Value).to_s

      #  puts "#{$coha['database']['driver']}"
        $coha["database"]['driver'] = Yast::UI.QueryWidget(Id(:driver), :Value).to_s
        puts "#{$coha['database']['driver']}"

      elsif ptab.to_s == "network_tab"
        #network
        puts "#{Yast::UI.QueryWidget(Id(:cb), :Value)}"
        $coha["network"]["port_number"] = Yast::UI.QueryWidget(Id(:networkport), :Value)
        $coha["network"]["query_port"] = Yast::UI.QueryWidget(Id(:queryport), :Value)

      elsif ptab.to_s == "general_tab"
        #general
        $coha['general']['debug_level'] = Yast::UI.QueryWidget(Id(:debug_level), :Value)
        $coha['general']['interval'] = Yast::UI.QueryWidget(Id(:interval), :Value)
      end
      #generell
      
    end

    def controller_loop

      while true do

 #         Yast::UI.ChangeWidget(Id(":networkport"), :Enabled, false)
 #         Yast::UI.ChangeWidget(Id(":queryport"), :Enabled, false)
 #         Yast::UI.ChangeWidget(Id(:networkport), :Enabled, true)
 #         Yast::UI.ChangeWidget(Id(":queryport"), :Enabled, true)
 
        prev_tab = Yast::UI.QueryWidget(Id(:tabs), :CurrentItem)
        input = Yast::UI.UserInput
        current_tab = Yast::UI.QueryWidget(Id(:tabs), :CurrentItem)

        case input
        when :exit
          return :ok
        when :save
          update_hash(current_tab)
          $parser.write_conf($coha) 
        when :general_tab
          update_hash(prev_tab)
          Yast::UI.ReplaceWidget(Id(":tab_contents"), general_page)
        when :network_tab
          update_hash(prev_tab)
          Yast::UI.ReplaceWidget(Id(":tab_contents"), network_page)
        when :database_tab
          update_hash(prev_tab)
          Yast::UI.ReplaceWidget(Id(":tab_contents"), database_page)
        else
          raise "Unknown action #{input}"
        end
      end
    end

    def headings
      Heading(_("SMBTAD - Configuration"))
    end
    
    def save_button
      PushButton(Id(:save), _("&Save"))
    end

    def generell_buttons
      PushButton(Id(:exit), _("&Exit"))      
    end
  end
end
