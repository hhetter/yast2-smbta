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

module Smbtad
  class SmbtadDialog

    include Yast::UIShortcuts
    include Yast::I18n
    @wd = {"LabelNetwork" => {"widget" => ":label_network", "label" => "Network Settings"},
           "UDS" => {"widget" => :custom, "custom_widget" => Frame( "SMBTAD Network Configuration", Left(CheckBox(Id(:cb)), "test"))}                    
          }

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
    

    def label_content(lcontent)
       Label("#{lcontent} Settings for the SMBTAD.")
    end
    
    def general_page
            VBox(HBox(label_content("General"), Empty(), 
            Left(VBox(HSquash(IntField("Debug Level", 0, 10, 0)), Empty(), 
            TimeField(Id(:interval), "Interval", "01:00:00")))))
    end

    def network_page
       VBox(Empty(),
            label_content("Network"),
            CheckBox(Id(":cb"), _("Unix Domain Socket?"), true),
            InputField(Id(":networkport"), "Networkport:"),
            InputField(Id(":queryport"), "Queryport:"),
            widget_descr = Builtins.union(
            Ops.get(@wd, "LabelNetwork", {})
           )
           )
    end

    def database_page
       VBox(Empty(),
            label_content("Database"),
            InputField(Id(":dbuser"),"User:", "postgres"),
            Password(Id(":dbpassword"), "Password:"),
            InputField(Id(":dbname"),"Databasename:", "smbtad"),
            InputField(Id(":dbhost"), "Host:", "localhost"),
            InputField(Id(":inetport"), "Port:"),
            InputField(Id(":ip_adress"), "IP:"),
            ComboBox(Id(":dbdriver"), "Select DB Driver", ["pgsql","mysql","sqlite3"]) 
            )
    end

    def controller_loop
      cb_status = true
      while true do

        cb_status = Yast::UI.QueryWidget(Id(":cb"), :Value)

        if cb_status == true
          Yast::UI.ChangeWidget(Id(":networkport"), :Enabled, false)
          Yast::UI.ChangeWidget(Id(":queryport"), :Enabled, false)
        else
          Yast::UI.ChangeWidget(Id(:networkport), :Enabled, true)
          Yast::UI.ChangeWidget(Id(":queryport"), :Enabled, true)
        end

        input = Yast::UI.WaitForEvent
        puts "#{cb_status}"
        puts "#{input}"
        case input["ID"]
        when :ok, :cancel, :exit
          return :ok
        when :save
          #Speichern der einstellungen
        when :general_tab
          Yast::UI.ReplaceWidget(Id(":tab_contents"), general_page)
        when :network_tab
          Yast::UI.ReplaceWidget(Id(":tab_contents"), network_page)
        when :database_tab
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
      PushButton(Id(":save"), _("&Save"))
    end

    def generell_buttons
      PushButton(Id(":exit"), _("&Exit"))      
    end
  end
end
