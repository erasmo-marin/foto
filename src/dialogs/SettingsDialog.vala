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
using Foto.Views;
using Foto.Widgets;
using Utils;

namespace Foto.Dialogs{

	public class SettingsDialog : Gtk.Dialog {
	
        Gtk.Switch use_dark_theme = new Gtk.Switch ();
        Gtk.Switch use_cache = new Gtk.Switch ();
        
		public SettingsDialog(){

            set_title(_("Preferences"));
            set_resizable(false);
            
            /* Set proper spacing */
            get_content_area ().margin_left = 12;
            get_content_area ().margin_right = 12;
            get_content_area ().margin_top = 12;
            get_content_area ().margin_bottom = 12;       


            var notebook = new Granite.Widgets.StaticNotebook(false);

			/* content grid 1*/
            var content_grid = new Gtk.Grid ();
            content_grid.row_spacing = 6;
            content_grid.column_spacing = 12;
            content_grid.margin_top = 12;
            content_grid.margin_bottom = 12;
            
            int row = 0;
            
            use_dark_theme.set_active(settings.use_dark_theme);
            add_option (content_grid, new LLabel.right (_("Use dark theme if available")), use_dark_theme, ref row);
            use_dark_theme.button_press_event.connect( () => {
            	settings.use_dark_theme = !settings.use_dark_theme;
            	return false;
            });
            
            Gdk.Color a_color;
           	Gdk.Color.parse(settings.album_viewer_background_color, out a_color);  
            var album_background_color = new ColorButton.with_color (a_color);
            album_background_color.set_use_alpha(false);
            add_option (content_grid, new LLabel.right (_("Album background color")), album_background_color, ref row);
            album_background_color.color_set.connect(() => {  	
            	Gdk.Color color; 
            	album_background_color.get_color(out color);
            	settings.album_viewer_background_color = color.to_string();
            });
            
            
           	Gdk.Color iv_color;
           	Gdk.Color.parse(settings.image_viewer_background_color, out iv_color);           	             
            var imageviewer_background_color = new ColorButton.with_color (iv_color);
            add_option (content_grid, new LLabel.right (_("Image viewer background color")), imageviewer_background_color, ref row);
           	imageviewer_background_color.color_set.connect(() => {  	
            	Gdk.Color color; 
            	imageviewer_background_color.get_color(out color);
            	settings.image_viewer_background_color = color.to_string();
            });
           	
            /*content grid 2*/
            var vbox = new Box(Gtk.Orientation.VERTICAL, 0);

            var content_grid2 = new Gtk.Grid ();
            content_grid2.row_spacing = 6;
            content_grid2.column_spacing = 12;
            content_grid2.margin_top = 12;
            content_grid2.margin_bottom = 12;
            
            int row2 = 0;

            use_cache.set_active(settings.use_cache);
            use_cache.button_press_event.connect( () => {
            	settings.use_cache = !settings.use_cache;
            	return false;
            });
            add_option (content_grid2, new LLabel.right (_("Use cache for thumbnails")), use_cache, ref row2);

            var sect_label = new LLabel.markup ("<b>"+ _("Empty Cache") +"</b>"); 
            sect_label.hexpand = true;
            sect_label.halign = Gtk.Align.START;

            string desc1 = _("Foto saves thumbnails of your pictures and albums and stores them in a cache.");
            var desc_label = new Label(desc1);

            var empty_cache = new Button.with_label(_("Empty cache"));
            empty_cache.hexpand = true;
            empty_cache.halign = Gtk.Align.END;
            empty_cache.clicked.connect(()=>{
                empty_cache.set_sensitive(false);
                Cache.empty_cache();
            });
            

            vbox.pack_start(content_grid2,false, false, 3);
            vbox.pack_start(sect_label,false, false, 3);
            vbox.pack_start(desc_label,false, false, 3);
            vbox.pack_start(empty_cache, false, false, 3);



            var behavior = new Gtk.Label(_("Interface"));
            notebook.append_page(content_grid, behavior);
            var behavior2 = new Gtk.Label(_("Cache"));
            notebook.append_page(vbox, behavior2);

           	((Gtk.Box)get_content_area()).pack_start(notebook);

            this.show_all();      	

			Gtk.Button reset = (Gtk.Button)add_button (_("Reset to defaults"),Gtk.ResponseType.NONE);
			reset.clicked.connect(()=>{
				settings.reset_to_defaults();
				use_dark_theme.set_active(settings.use_dark_theme);
           		Gdk.Color.parse(settings.image_viewer_background_color, out iv_color);           	             
            	imageviewer_background_color.set_color (iv_color);
           		Gdk.Color.parse(settings.album_viewer_background_color, out a_color);  
            	album_background_color.set_color (a_color);			
			});			
			
            add_buttons("gtk-close", Gtk.ResponseType.CLOSE);
		}
		
        void add_option (Gtk.Grid grid, Gtk.Widget label, Gtk.Widget switcher, ref int row) {
            label.hexpand = true;
            label.halign = Gtk.Align.END;
            switcher.halign = Gtk.Align.FILL;
            switcher.hexpand = true;
            
            if (switcher is Gtk.Switch || switcher is Gtk.CheckButton
                || switcher is Gtk.Entry || switcher is ColorButton) { /* then we don't want it to be expanded */
                switcher.halign = Gtk.Align.START;
            }
            
            grid.attach (label, 0, row, 1, 1);
            grid.attach_next_to (switcher, label, Gtk.PositionType.RIGHT, 3, 1);
            row ++;
        }
	
		
    }
}