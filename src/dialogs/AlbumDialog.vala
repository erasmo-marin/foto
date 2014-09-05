// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2014 Foto Developers (http://launchpad.net/foto)
 *
 * This software is licensed under the GNU General Public License
 * (version 3 or later). See the COPYING file in this distribution.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Erasmo Marín <erasmo.marin@gmail.com>
 */

using Gtk;
using Foto.Widgets;

namespace Foto.Dialogs {

public class AlbumDialog : Granite.Widgets.LightWindow {
        /**
         * The different widgets in the dialog that we need to save.
         */
		Album album;
        Gtk.Entry albumname_entry;
        Gtk.TextView description_textview;
        LLabel error_label;
        Gtk.Button cancel_button;
        Gtk.Button create_button;
        ColorRow color_row;

        public AlbumDialog (Album? album) {

			 this.album = album;
             //widgets
             albumname_entry = new Granite.Widgets.HintedEntry (_("My album"));
             description_textview = new Gtk.TextView ();
             description_textview.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);
             cancel_button = new Gtk.Button.from_stock (Gtk.Stock.CANCEL);

             if(album == null) {
                create_button = new Gtk.Button.with_label (_("Create Album"));
                create_button.clicked.connect (save);
             } else{
                TextBuffer text_buffer = new TextBuffer(null);
                text_buffer.text = album.comment;
                create_button = new Gtk.Button.with_label (_("Save changes"));
                create_button.clicked.connect (edit);
                description_textview.set_buffer(text_buffer);
                albumname_entry.set_text(album.album_name);
             }

             error_label = new LLabel.markup_center("<span foreground='red'></span>");
             cancel_button.clicked.connect (() => {this.destroy();});

             //scrolledwindow for description textview
             var scrolled = new Gtk.ScrolledWindow (null, null);
             scrolled.add (description_textview);
             scrolled.height_request = 100;
             scrolled.set_vexpand(true);
             scrolled.set_hexpand(true);

             //buttonbox
             var buttonbox = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
             buttonbox.set_layout (Gtk.ButtonBoxStyle.END);
             buttonbox.pack_end (cancel_button);
             buttonbox.pack_end (create_button);
             create_button.margin_right = 5;

             //colorrow
             color_row = new ColorRow(12);
 
             //content grid with all the stuff in it
           	 var content_grid = new Gtk.Grid ();
             content_grid = new Gtk.Grid ();
             content_grid.margin_left = 12;
             content_grid.margin_right = 12;
             content_grid.margin_top = 12;
             content_grid.margin_bottom = 12;
             content_grid.set_row_spacing (6);
             content_grid.set_column_spacing (12);

             content_grid.attach (new LLabel(_("Album name:")), 0, 1, 1, 1);
             content_grid.attach (albumname_entry, 0, 2, 1, 1);
             content_grid.attach (color_row, 0, 3, 1, 1);
             content_grid.attach (new LLabel(_("Description:")), 0, 4, 1, 1);

             content_grid.attach (scrolled, 0, 5, 1, 1);
             content_grid.attach (error_label, 0, 6, 1, 1);    
             content_grid.attach (buttonbox, 0, 7, 1, 1);

           	 this.add (content_grid);
             this.albumname_entry.changed.connect(validate_album_name);
           	 this.show_all ();
        }

    private void validate_album_name(){

        /*if(album_manager.album_name_exists(albumname_entry.get_text())){
                add_error(_("Album already exists"));
                create_button.set_sensitive(false);
        }
        else{
                remove_error();
                create_button.set_sensitive(true);
        }*/
    }

    private void save(){

        string album_name, comment;
        int color;
        album_name = albumname_entry.get_text();
        comment = description_textview.get_buffer().text;
        color = RowPalette.serialize(color_row.color_string);


        bool destroy = true;

        //FIXME: we need to validate this string (blanks like "    " and strange simbols)
        if(album_name != "") {
            var creation_date = new GLib.DateTime.now_local ();
            var albumdao = AlbumDAO.get_instance ();
            //FIXME: 2038 problem
            var album = new Album.with_values(null, album_name, (int)creation_date.to_unix (), comment, 0, color);
          
            if(!albumdao.insert(album)){
                add_error(_("Album already exists"));
                destroy = false;
            }
        }
        if(destroy)
            this.destroy();
    }


    private void edit(){
		//var album = album_manager.get_album_by_name();
		string last_album_name, albumname, description;
        albumname = albumname_entry.get_text();
        description = description_textview.get_buffer().text;
        //last_album_name = album.album_name;
        bool destroy = true;
        
        if(albumname != ""){
			//if user changed the album name, we need to validate that the new name doesn't exists
			/*if(albumname != last_album_name && album_manager.get_album_by_name(albumname) != null){
                add_error(_("Album already exists"));
                destroy = false;
            }
            else{
            	var new_album = new Album(albumname, description, album.creation_date,null, 3);
				album_manager.update_album(last_album_name, new_album);
            }  */         
        }
        if(destroy)
            this.destroy();
    }

    private void add_error(string error){
        error_label.label = "<span foreground='red'>" + error + "</span>";
    }

    private void remove_error(){
        error_label.label = "";
    }


    }


}