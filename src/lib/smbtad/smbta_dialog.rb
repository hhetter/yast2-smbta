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
            Left(DumbTab(Id(:tabs), tab_labels, ReplacePoint(Id(":tab_contents"), VBox(Empty()))))
            ),

         #config_table                      
            Right(Bottom(generell_buttons))
          )
    end

    def label_content(lcontent)
       Label("#{lcontent} Settings for the SMBTAD.")
    end

    def general_page
       HBox(label_content("General"), Empty(), 
            HWeight( 10, IntField("Debug Level", 0, 10, 0)))
    end

    def network_page
       label_content("Network")
    end

    def database_page
       VBox(label_content("Database"),
            InputField(Id(":dbuser"),"User:"),
            Password(Id(":dbpassword"), "Password:"),
            InputField(Id(":dbname"),"Databasename:"),
            InputField(Id(":dbhost"), "Host:"),
            InputField(Id(":inetport"), "Port:") 
            
            )
    end

    def controller_loop
      while true do
       # input = Yast::UI.UserInput
        input = Yast::UI.WaitForEvent["ID"]
        #PUTS zu testzwecken
        puts "#{input}"
        case input
        when :ok, :cancel, :exit
          return :ok
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

    def config_table
      Table(
        Header( "Foo", "Bar"),
        [ Item( Id(1), "foo", "bar" )]
      )
    end

    def content
      Item(
          Id(1),
          "bar",
          "foobar"
        )
    end

    def headings
      Heading(_("SMBTAD - Configuration"))
    end

    def generell_buttons
     # PushButton(Id(":save"), _("&Save")),
      PushButton(Id(":exit"), _("&Exit"))      
    end
  end
end
