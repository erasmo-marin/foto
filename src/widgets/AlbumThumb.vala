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
using Utils;

namespace Foto.Widgets{


    /*  AlbumIcon: A very simple widget that emulates a stack of pics.
     *  The ammount of pics is given by the "album_size" parameter.
     *  If an album haves more than 5 pics, only 5 frames will be drawn,
     *  because more than 5 frames makes it looks saturated.
     */
    public class AlbumIcon : Gtk.DrawingArea {

        private string pic_filename;

        //pixbuf that stores the thumbnail
        private Pixbuf thumb;
        //pixbuf that stores the white frame, it's static because all the AlbumIcon instances uses the same
        private static Pixbuf pix;
        private static Pixbuf pix_prelight;

        //widget width and height
        private int width = 180;
        private int height = 140;

        //aproximated 4:3
        private int thumb_width = 120;
        private int thumb_height = 90;

        //4:3
        private int frame_width = 142;
        private int frame_height = 112;

        private Pixbuf close_button;
        private Pixbuf edit_button;

        //close button values
        private int close_x;
        private int close_y;
    
        //edit button values
        private int edit_x;
        private int edit_y;

        private struct frame_value{
            int x; //the x position where the frame will be drawn
            int y; //the y position where the frame will be drawn
            double angle; //the rotation angle of the frame
        }
        //TODO: Improve these values
        //frame_values contains known values that works fine for frames
        static const frame_value[] frame_values = {
                                            {20, 13, 0.05},
                                            {11, 21, -0.05},
                                            {20, 13, 0.07}, 
                                            {11, 23, -0.07},
                                            {9, 25, -0.09},
                                            {22, 11, 0.09},
                                            };
        //the pattern of the widget
        private frame_value[] pattern;
        //the pics inside the album
        private uint album_size;

        //signals
        public virtual signal void edit_event(){
            debug("Edit event");
        }
        public virtual signal void close_event(){
            debug("Close event");
        }
        public virtual signal void icon_clicked_event(){
            debug("Icon clicked event");
        }

        public AlbumIcon (string? pic_filename, uint album_size) {

            this.set_size_request (width, height);
            this.set_vexpand (false);
            this.set_hexpand (false);
            this.halign = Align.CENTER;
            this.valign = Align.CENTER;

            add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                        | Gdk.EventMask.BUTTON_RELEASE_MASK 
                        | Gdk.EventMask.LEAVE_NOTIFY_MASK 
                        | Gdk.EventMask.ENTER_NOTIFY_MASK );

			close_button = Utils.IconFactory.get_icon (Utils.IconFactory.IconType.ICON_CLOSE_BUTTON);
			edit_button = Utils.IconFactory.get_icon (Utils.IconFactory.IconType.ICON_EDIT_BUTTON);

            button_release_event.connect((event) => { 

                //if user clicks close button
                if (event.x>= close_x && event.x<= close_x+32 && event.y>= close_y && event.y <= close_y +32){
			        close_event();
                    this.set_state_flags (StateFlags.NORMAL,true);
                    return false;
                }

                //if user clicks edit button
                else if (event.x>= edit_x && event.x<= edit_x+32 && event.y>= edit_y && event.y <= edit_y +32){
			        edit_event();
                    this.set_state_flags (StateFlags.NORMAL,true);
                    return false;
                }

                //if user clicks icon 
                else{
			        icon_clicked_event ();
                    this.set_state_flags (StateFlags.NORMAL,true);
                    return false;
                }     
            });

            if (pic_filename != null) {     
                this.set_from_file (pic_filename, album_size);
            }
        }

        //Draw
        public override bool draw (Cairo.Context cr){

            if (album_size==0){
                if (get_state_flags() == StateFlags.PRELIGHT)
                    cr.set_source_rgba (1,1,1,0.9);
                else
                    cr.set_source_rgba (1,1,1,0.7);                    
                Utilities.cairo_rounded_rectangle (cr, 17, 18, 150, 113, 5);
                cr.set_dash (new double[] { (137.999)/19, (137.95)/15.905}, 6);
                cr.set_line_width (4);
                cr.stroke ();
                draw_buttons (cr);
                return false;
            }

            Pixbuf frame;
            if (get_state_flags() == StateFlags.PRELIGHT)
                frame = pix_prelight;
            else
                frame = pix;

            if (album_size>1){
                for (int i=0;i<=(album_size-3);i++) {
                    draw_frame (cr, frame, pattern[i].x, pattern[i].y, pattern[i].angle);
                }
            }
            //picture frame
            draw_frame (cr, frame, 17, 18, 0);
            //thumb
            draw_frame (cr, thumb, 28, 28, 0);
            draw_buttons (cr);
            return false;
        }

        private void draw_buttons (Cairo.Context cr) {

            //draw close button
            if (close_button != null && get_state_flags() == StateFlags.PRELIGHT) {
        	    close_x = 9;
        	    close_y = 9;
        	    Gdk.cairo_set_source_pixbuf (cr,close_button,close_x,close_y);
        	    cr.paint ();
            }        
        
            //draw edit button
            if (edit_button != null && get_state_flags() == StateFlags.PRELIGHT) {
        	    edit_x = this.get_allocated_width () - 32 - 9;
        	    edit_y = 9;
        	    Gdk.cairo_set_source_pixbuf (cr,edit_button, edit_x, edit_y);
        	    cr.paint ();
            }   

        }

        private void draw_pix () {

            Granite.Drawing.BufferSurface buffer_surface;

            if (pix == null) {

                buffer_surface = new Granite.Drawing.BufferSurface (frame_width, frame_height);
                buffer_surface.context.set_source_rgba (1,1,1,1);
                buffer_surface.context.rectangle (0, 0, frame_width, frame_height);
                buffer_surface.context.fill ();

                pix = buffer_surface.load_to_pixbuf ();
                buffer_surface.clear();

                Gdk.cairo_set_source_pixbuf (buffer_surface.context,
                                             PixbufUtils.render_box_shadow ( pix, frame_width, frame_height), 
                                             0, 0);
                buffer_surface.context.paint();
                pix = buffer_surface.load_to_pixbuf ();

            }

            if (pix_prelight == null) {
                buffer_surface = new Granite.Drawing.BufferSurface (frame_width, frame_height);
                Gdk.cairo_set_source_pixbuf (buffer_surface.context, pix, 0, 0);
                buffer_surface.context.paint ();
                buffer_surface.context.paint ();
                pix_prelight = buffer_surface.load_to_pixbuf ();
            }
        }

        //randomly creates a pattern of overlaped frames
        private void compute_pattern () {
            int[] values = {};
            if (album_size>1) {
                var datetime = new GLib.DateTime.now_local ();
                GLib.Random.set_seed (datetime.get_microsecond ());
                for(int i=0; i<=(album_size-2); i++){
                    int val = 0;
                    do{
                        val = GLib.Random.int_range (0, 6);
                    } while (val in values);
                    values += val;        
                    pattern += frame_values[val];
                }
            }
        }


        private void draw_frame (Cairo.Context cr, Pixbuf pix, int x, int y, double angle) {
            cr.rotate (angle);
            cairo_set_source_pixbuf (cr, pix, x, y);
            cr.paint ();
            cr.rotate (-1*angle);
        }


        public void set_from_pixbuf (Pixbuf thumb, uint album_size) {

            var thumbnail = thumb;
            if (album_size>4) this.album_size = 4;
            else this.album_size = album_size;

            if(thumbnail.get_width () > thumbnail.get_height ()){
                double new_width = ( (double) thumbnail.get_width()*thumb_height)/ (double) thumbnail.get_height ();
                if (new_width < thumb_width) 
                    new_width = thumb_width; 
                thumbnail = thumbnail.scale_simple ( (int) new_width, thumb_height, InterpType.HYPER);
            } else {
                double new_height = ( (double) thumbnail.get_height () * thumb_width)/ (double) thumbnail.get_width ();
                if (new_height < thumb_height) 
                    new_height = thumb_height; 
                thumbnail = thumbnail.scale_simple (thumb_width, (int) new_height, InterpType.HYPER);
            }

            if (thumbnail.get_height () > thumbnail.get_width () ) {
                double y = (double) (thumbnail.get_height() - thumb_height)/2.0;
                thumbnail = new Pixbuf.subpixbuf (thumbnail, 0, (int) y, thumb_width, thumb_height);
            } else {
                double x = (double) (thumbnail.get_width() - thumb_width)/2.0;
                thumbnail = new Pixbuf.subpixbuf (thumbnail, (int) x, 0, thumb_width, thumb_height);
            }

            draw_pix ();
            compute_pattern ();
            this.thumb = thumbnail;
            this.queue_draw ();
        }

        public void set_from_file (string pic_filename, uint album_size) {

                this.pic_filename = pic_filename;
                Pixbuf thumb_aux = null;

                try {
                    if (settings.use_cache)
                        thumb_aux = Cache.get_cached_image (pic_filename);
                    if (thumb_aux == null)
                        thumb_aux = new Pixbuf.from_file (pic_filename);
                } catch (GLib.Error error) {
                    thumb_aux = Utils.IconFactory.get_icon (Utils.IconFactory.IconType.ICON_IMAGE_MISSING);
		        }
                set_from_pixbuf (thumb_aux, album_size);
        }


	    //EVENTS

        /* Mouse button got pressed over widget */
        public override bool button_press_event (Gdk.EventButton event) {
            this.set_state_flags (StateFlags.FOCUSED,true);
            return false;
        }

        /* Mouse button got released */
        public override bool button_release_event (Gdk.EventButton event) {
            return false;
        }

        public override bool enter_notify_event (Gdk.EventCrossing event) {
            this.set_state_flags (StateFlags.PRELIGHT,true);
            return false;
        }

        public override bool leave_notify_event (EventCrossing event){
            this.set_state_flags (StateFlags.NORMAL,true);
            return false;
        }
    
    }
}