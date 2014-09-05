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

using Foto.Widgets;

namespace Foto.Dialogs{

    public class PropertiesDialog : Granite.Widgets.LightWindow {

        Gtk.Widget relative_to;
        Gtk.Grid grid;
        ulong handler_id = 0;

		public PropertiesDialog(Picture picture, Gtk.Widget relative_to) {

            base(_("Properties"));

            var photo = new Photo(picture);
            var metadata = photo.get_metadata();

            this.relative_to = relative_to;
            var stack = new Gtk.Stack();
            grid = new Gtk.Grid();

           	var general = new Gtk.Grid ();
           	general.attach (new LLabel.markup (_("<b>Info:</b>")), 0, 0, 2, 1);
            
           	general.attach (new LLabel.right (_("Created:")), 0, 1, 1, 1);
           	general.attach (new LLabel.right (_("Mimetype:")), 0, 2, 1, 1);
           	general.attach (new LLabel.right (_("Location:")), 0, 3, 1, 1);
            
           	general.attach (new LLabel ("Today at 9:50 PM"), 1, 1, 1, 1);
           	general.attach (new LLabel (photo.get_mime_type()), 1, 2, 1, 1);
           	general.attach (new LLabel (photo.get_path()), 1, 3, 1, 1);

            general.set_column_spacing (10);
            general.set_row_spacing (3);

            var more = new Gtk.Grid ();
            more.row_homogeneous = true;
           	more.attach (new LLabel.markup (_("<b>Metadata:</b>")), 0, 0, 2, 1);

            var camera_model = metadata.get_camera_model();
            var comment = metadata.get_comment();
            var focal_length = metadata.get_focal_length_string();
            var resolution = "1280x800 px";
            var rating = metadata.get_rating();
            var author = metadata.get_artist();
            var copyright = metadata.get_copyright();
            var software = metadata.get_software();
            int row = 1;
            
            if (camera_model != null && camera_model.length > 0) {
               	more.attach (new LLabel.right (_("Camera model:")), 0, row, 1, 1);
                more.attach (new LLabel (camera_model), 1, row, 1, 1);
                row++;
            }

            if (comment != null && comment.length > 0) {
               	more.attach (new LLabel.right (_("Comment:")), 0, row, 1, 1);
                more.attach (new LLabel (comment), 1, row, 1, 1);
                row++;
            }


            if (focal_length != null && focal_length.length > 0) {
               	more.attach (new LLabel.right (_("Focal length:")), 0, row, 1, 1);
                more.attach (new LLabel (focal_length), 1, row, 1, 1);
                row++;
            }

            if (resolution != null && resolution.length > 0) {
               	more.attach (new LLabel.right (_("Resolution:")), 0, row, 1, 1);
                more.attach (new LLabel (resolution), 1, row, 1, 1);
                row++;
            }


            if (author != null && author.length > 0) {
               	more.attach (new LLabel.right (_("Author:")), 0, row, 1, 1);
                more.attach (new LLabel (author), 1, row, 1, 1);
            }

            if (copyright != null && copyright.length > 0) {
               	more.attach (new LLabel.right (_("CopyRight:")), 0, row, 1, 1);
                more.attach (new LLabel (copyright), 1, row, 1, 1);
                row++;
            }

            if (software != null && software.length > 0) {
               	more.attach (new LLabel.right (_("Software:")), 0, row, 1, 1);
                more.attach (new LLabel (software), 1, row, 1, 1);
                row++;
            }

           	more.attach (new LLabel.right (_("Rating:")), 0, row, 1, 1);
            more.attach (new Rating(rating), 1, row, 1, 1);

            more.set_column_spacing (10);
            more.set_row_spacing (3);

           	grid.attach (new Gtk.Image.from_icon_name ("image-x-generic", Gtk.IconSize.DIALOG), 0, 0, 1, 2);
           	grid.attach (new LLabel ("foto.jpg"), 1, 0, 1, 1);
           	grid.attach (new LLabel ("2.1 mb, jpeg image file"), 1, 1, 1, 1);

            stack.add_titled (general,"1",_("General"));
            stack.add_titled (more,"2",_("More"));
            stack.set_transition_duration(500);
            stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
            stack.set_visible_child(general);


            var switcher = new Gtk.StackSwitcher ();
            switcher.set_stack (stack);
            switcher.set_halign(Gtk.Align.CENTER);

            grid.attach (switcher, 0, 2, 2, 1);
            grid.attach (stack, 0, 3, 2, 1);
            grid.set_row_spacing (10);
            grid.set_margin_left(20);
            grid.set_margin_right(20);
            grid.set_margin_bottom(40);

            this.add (grid);
            handler_id = this.size_allocate.connect (move_to_relative_parent);
            this.show_all();
        }

	    //Move the PropertiesWindow to the center of the window 
	    private void move_to_relative_parent(Gtk.Allocation allocation) {

            int toplevel_x;
            int toplevel_y;
            int x;
            int y;

            var window = relative_to.get_window();

            window.get_toplevel().get_position(out toplevel_x, out toplevel_y);
            window.get_position(out x, out y);

            x = x + toplevel_x + relative_to.get_allocated_width()/2;
            y = y + toplevel_y + relative_to.get_allocated_height()/2 - allocation.height/2;

		    this.move(x,y);
            this.disconnect(handler_id);
        }
    }
}