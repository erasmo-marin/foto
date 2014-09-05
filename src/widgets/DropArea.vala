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
using Gdk;
using Cairo;
using Granite.Drawing;

namespace Foto.Widgets{

public class DropArea : Gtk.EventBox {


    public RGBA dash_color;
    public string title {set;get;}
    public string subtitle {set;get;}
    private int margin_x=50;
    private int margin_y=50;
    private int line_width = 4;
    private double line_step = 20;
    private double line_spacing = 7;

    public signal void files_dropped(File[] files);

    public DropArea (string? title, string? subtitle) {

        this.set_app_paintable(true);
        this.title = title;
        this.subtitle = subtitle;
        dash_color = {1,1,1,0.6};
        this.support_drag_and_drop ();
        this.set_size_request (500,250);
        this.set_hexpand(true);
        this.set_vexpand(true);

        this.drag_motion.connect(() => {            
            this.set_state_flags (StateFlags.FOCUSED, true);
            return false;
        });

        this.drag_leave.connect(() => {            
            this.set_state_flags (StateFlags.NORMAL, true);
        });

        this.state_changed.connect(() => {
            if(get_state_flags () == StateFlags.FOCUSED) {
                dash_color = {1,1,1,0.9};
            } else {
                dash_color = {1,1,1,0.6};
            }
        });
        this.draw.connect (on_draw);

        var slabel = new LLabel.markup ("<span foreground='#ffffff'>"+ subtitle + _(", or ") + "<a href=\"Browse\">" + _("Browse") + "</a></span>");
        slabel.halign = Align.CENTER;
        slabel.valign= Align.CENTER;
        slabel.activate_link.connect(on_link_activated);
        this.add (slabel);

    }
   


    //Draw a dashed line and centered text
    public bool on_draw (Cairo.Context cr) {

        int width = this.get_allocated_width();
        int height = this. get_allocated_height();
        int start_x = margin_x + line_width/2;
        int start_y = margin_y + line_width/2;

        width = this.get_allocated_width() - 2*start_x;
        height = this. get_allocated_height() - 2*start_y;

        //draw text
        cr.set_font_size(30);
        TextExtents title_extents;
        cr.text_extents (this.title, out title_extents);
        double title_text_x = (this.get_allocated_width() - title_extents.width)/2;
        double title_text_y = (this.get_allocated_height() - title_extents.height)/2;
        cr.set_source_rgba (0,0,0,1);
        cr.move_to(title_text_x - 2, title_text_y - 2);
        cr.show_text(this.title);
        cr.set_source_rgba (1,1,1,0.9);
        cr.move_to(title_text_x, title_text_y);
        cr.show_text(this.title);

        //draw rectangle
        cr.set_source_rgba (dash_color.red, 
                            dash_color.green, 
                            dash_color.blue, 
                            dash_color.alpha);

        Utilities.cairo_rounded_rectangle (cr,start_x, start_y,width,height, 10);
        cr.set_dash (new double[] {line_step, line_spacing},6);
        cr.set_line_width(this.line_width);
        cr.stroke ();
        cr.set_dash (null, 0);
        return false;
    }


    private void support_drag_and_drop () {

        Gtk.drag_dest_set (this, DestDefaults.ALL, {}, Gdk.DragAction.COPY);
        Gtk.drag_dest_add_uri_targets (this);
        this.drag_data_received.connect ((dc, x, y, selection_data, info, time) => {
            File[] files = {};
            foreach (string uri in selection_data.get_uris ()) {
                if (0 < uri.length) {
                    var new_file = File.new_for_uri (uri);
                    files += new_file;
                }
            }
            Gtk.drag_finish (dc, true, true, time);
            files_dropped(files);
        });
    }


    //TODO: Import
    private bool on_link_activated (string uri) {

        if(uri != "Browse") return false;

	    var filter = new Gtk.FileFilter ();
	    filter.set_filter_name (_("Images"));
        //FIXME: Create enumeration with all the supported formats supported by foto and load patterns from there
	    filter.add_pattern ("*.png");
	    filter.add_pattern ("*.svg");
	    filter.add_pattern ("*.jpg");
	    filter.add_pattern ("*.jpeg");
	    filter.add_pattern ("*.bmp");
	    filter.add_pattern ("*.PNG");
	    filter.add_pattern ("*.SVG");
	    filter.add_pattern ("*.JPG");
	    filter.add_pattern ("*.JPEG");
	    filter.add_pattern ("*.BPM");

        var file_chooser = new FileChooserDialog ("", null,
                                                   FileChooserAction.OPEN,
                                                   Stock.CANCEL, ResponseType.CANCEL,
                                                   Stock.OPEN, ResponseType.ACCEPT);
        file_chooser.set_select_multiple(true);
        file_chooser.add_filter (filter);

        var preview = new Image();
        preview.valign = Align.START;
        file_chooser.set_preview_widget (preview);
        file_chooser.update_preview.connect(()=> {

            string filename = file_chooser.get_preview_filename();
            Pixbuf pix = null;

            try {
                pix = new Pixbuf.from_file_at_size(filename, 128, 128);
			} catch (GLib.Error error) {
                 warning("There was a problem loading preview.");
		    }

            if(pix!=null){
                preview.set_from_pixbuf(pix);
                file_chooser.set_preview_widget_active(true);
            }
        });

        if (file_chooser.run () == ResponseType.ACCEPT) {

            File[] files = {};
            SList<File> picslist = file_chooser.get_files();

            foreach(File file in picslist){
                files += file;
            }
            file_chooser.destroy ();
            files_dropped(files);
        }
        file_chooser.destroy ();
        return true;
    }
}
}