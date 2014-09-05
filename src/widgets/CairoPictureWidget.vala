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

using Gdk;
using Gtk;
using Cairo;

namespace Foto.Widgets{


/* The rotation type. Used with PictureWidget.rotate()
 */
public enum RotationType{
    LEFT,
    RIGHT
}


/* A Widget that shows an image and allows zooming, drag
 * and simple rotations.
 */
public class PictureWidget : Gtk.ScrolledWindow {

    public signal void drag_action(EventMotion event);
    public signal void drag_action_begin(EventMotion event);
    public signal void drag_action_end(EventMotion event);
    public signal void scale_changed(double scale);
    public signal void right_clicked();
    public signal void double_clicked();

    private double drag_action_x;
    private double drag_action_y;

    private DrawingArea drawing_area;
    private Gdk.Color bg_color;
    private Pixbuf pic_buffer;

    //FIXME: min_scale and max_scale shouldn't be fixed values.
    private double scale = 1;
    private double min_scale = 0.1;
    private double max_scale = 2;

    private bool use_best_fit = true;
    //How the scale change
    private double zoom_step = 0.02;

    public PictureWidget() {

        	Gdk.Color.parse ("000000", out bg_color);
            
            drawing_area = new DrawingArea();
            drawing_area.draw.connect(on_draw);
		    drawing_area.halign = Align.CENTER;
		    drawing_area.valign = Align.CENTER;
    
            border_width = 0;

            this.add_with_viewport(drawing_area);
            this.set_policy(PolicyType.AUTOMATIC , PolicyType.AUTOMATIC);
            this.shadow_type = Gtk.ShadowType.NONE;
            drawing_area.vexpand = true;
            drawing_area.hexpand = true;

            drawing_area.add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                      | Gdk.EventMask.BUTTON_RELEASE_MASK
                      | Gdk.EventMask.POINTER_MOTION_MASK
                      | Gdk.EventMask.SCROLL_MASK
                      | Gdk.EventMask.KEY_PRESS_MASK );

            center_scrollbars();
            implement_draggable();

            drag_action.connect(on_drag_action);
            drag_action_begin.connect(on_drag_action_begin);
            drag_action_end.connect(on_drag_action_end);

            drawing_area.button_release_event.connect((event)=>{
                if (event.button == 3)
                    right_clicked();
                return false;
            });

            this.button_press_event.connect((event)=>{
                if(event.type == Gdk.EventType.@2BUTTON_PRESS) {
                        double_clicked();
                        debug("PictureWidget.DoubleClick");
                }
                return false;
            });

            this.key_press_event.connect (on_key_press);
    }

    //FIXME: Remove warning showing "instance has no handler with id ...."
    private void implement_draggable() {

        ulong handler_id=0;
        EventMotion e = null;
        bool drag_started = false;

        drawing_area.button_press_event.connect((event)=>{

            if (event.button != 1 || event.type == Gdk.EventType.@2BUTTON_PRESS)
                return false;

            drag_started = false;

            handler_id =
            drawing_area.motion_notify_event.connect((event)=>{
                if (!drag_started) {
                    drag_started = true;
                    drag_action_begin(event);
                }
                drag_action(event);
                e=event;
                return false;
            });
            return false;
        });

        drawing_area.button_release_event.connect((event)=>{
            if (event.button != 1)
                return false;
            drawing_area.disconnect(handler_id);
            drag_started = false;
            if(e != null)
                drag_action_end(e);
            return false;
        });
    }


    private void on_drag_action_begin(EventMotion event) {
        drag_action_x = event.x;
        drag_action_y = event.y;
        Gdk.Cursor cursor = new Gdk.Cursor(Gdk.CursorType.FLEUR);
        Gdk.Window window = drawing_area.get_window();
        window.set_cursor(cursor);
    }

    private void on_drag_action(EventMotion event) {

        var va = this.get_vadjustment();
        var ha = this.get_hadjustment();


        double new_hadjustment = ha.value + (drag_action_x - event.x);
        double new_vadjustment = va.value + (drag_action_y - event.y);

        ha.value = new_hadjustment;
        va.value = new_vadjustment;

    }

    private void on_drag_action_end(EventMotion event) {
        Gdk.Cursor cursor = new Gdk.Cursor(Gdk.CursorType.ARROW);
        Gdk.Window window = drawing_area.get_window();
        window.set_cursor(cursor);
    }

    public void set_image(string file_path){

		try {
            pic_buffer = new Pixbuf.from_file(file_path);
		} catch (GLib.Error error) {
			warning(error.message);
            return;
		}
        set_best_fit(true);
        queue_draw();
    }

    private double get_best_fit_scale() {

        int width = get_parent().get_allocated_width();
        int height = get_parent().get_allocated_height();

        double rf = (double)width/(double)pic_buffer.get_width();
        int p = (int)(pic_buffer.get_height() * rf);

        double scale;

        if(p <= height) {
              scale = (double)width/(double)pic_buffer.get_width();
              return scale;
        } else {
              scale = (double)height/(double)pic_buffer.get_height();
              return scale;
        }
    }


    /* Widget is asked to draw itself */
    public bool on_draw (Cairo.Context cr) {

        if(pic_buffer == null)
            return true;

        if(use_best_fit) {
            set_scale_internal(get_best_fit_scale());
        }

        if(this.scale != 1) {
            cr.scale(this.scale, this.scale);
        }

        cairo_set_source_pixbuf (cr, pic_buffer, 0, 0);
        cr.paint();
             
        return true;
    }


    private void on_scroll_up() {
        use_best_fit = false;
        zoom_in();
    }

    private void on_scroll_down() {
        use_best_fit = false;
        zoom_out();
    }

    public void rotate(RotationType rotation) {
        if(rotation == RotationType.LEFT)
            pic_buffer = pic_buffer.rotate_simple(PixbufRotation.COUNTERCLOCKWISE);
        else
            pic_buffer = pic_buffer.rotate_simple(PixbufRotation.CLOCKWISE);

        set_best_fit(true);        
    }

    private void set_scale_internal(double scale) {
        if(scale > max_scale || scale < min_scale || this.scale == scale)
            return;

        this.scale = scale;
        drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
        center_scrollbars();
        scale_changed(scale);
        drawing_area.queue_draw();
    }

    public void set_scale(double scale) {
        if(scale > max_scale || scale < min_scale || this.scale == scale)
            return;
        use_best_fit = false;
        set_scale_internal(scale);
    }

    public double get_scale() {
        return scale;
    }

    public void set_best_fit(bool use_best_fit) {
        this.use_best_fit = use_best_fit;
        scale = get_best_fit_scale();
        drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
        drawing_area.queue_draw();
    }

    public Pixbuf? get_image_pixbuf() {
        return pic_buffer;
    }

    private bool on_key_press (EventKey e) {

        print("Keypress");
        switch (e.keyval) {
            case Gdk.Key.Escape:
                break;
            case Gdk.Key.F11:
                break;
        }
        return false;
    }

    
    /*this does not work "nicely" as expected
        public void animated_zoom_in() {
        if (scale + zoom_step > max_scale)
            return;

        //initial delta
        double delta = scale - ((double)pic_buffer.get_width()*scale - 1)/((double)pic_buffer.get_width());
        int iterations = 100;

        for(int i = 0; i<iterations; i++) {
            drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
            scale+=delta;
            drawing_area.queue_draw();
            drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
            center_scrollbars();
            scale_changed(scale);
            while (Gtk.events_pending())
                Gtk.main_iteration();
            Thread.usleep(1000);
            delta = scale - ((double)pic_buffer.get_width()*scale - 1)/((double)pic_buffer.get_width());
            iterations = (int)(zoom_step/delta);
        }
    }

    public void animated_zoom_out() {
        if (scale - zoom_step < min_scale)
            return;

        //initial delta
        double delta = ((double)pic_buffer.get_width()*scale + 1)/((double)pic_buffer.get_width()) - scale;
        int iterations = 100;


        for(int i = 0; i<iterations; i++) {
            drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
            scale-=delta;
            drawing_area.queue_draw();
            drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
            center_scrollbars();
            scale_changed(scale);
            while (Gtk.events_pending())
                Gtk.main_iteration();
            Thread.usleep(500);
            delta = ((double)pic_buffer.get_width()*scale + 1)/((double)pic_buffer.get_width()) - scale;
            iterations = (int)(zoom_step/delta);
        }
    }*/



    public void zoom_out() {
        if (scale - zoom_step < min_scale)
            return;

        drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
        scale-=zoom_step;
        drawing_area.queue_draw();
        drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
        center_scrollbars();
        scale_changed(scale);
    }



    public void zoom_in() {
        if (scale + zoom_step > max_scale)
            return;

        drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
        scale+=zoom_step;
        drawing_area.queue_draw();
        drawing_area.set_size_request((int)(pic_buffer.get_width()*scale), (int)(pic_buffer.get_height()*scale));
        center_scrollbars();
        scale_changed(scale);
    }


    private void center_scrollbars() {
        var va = this.get_vadjustment();
        var ha = this.get_hadjustment();
    
        va.changed.connect(() => {
            va.set_value((va.upper - va.page_size)/2);
        });

        ha.changed.connect(() => {
            ha.set_value((ha.upper - ha.page_size)/2);
        });
    }

    public override bool scroll_event (EventScroll event) {
        if(event.direction == ScrollDirection.UP){
            on_scroll_up();
        }
        else if(event.direction == ScrollDirection.DOWN){
            on_scroll_down();
        }
        
        return false;
    }
}
}