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

public class SlideshowWindow : Gtk.Window {

    private Foto.Widgets.PictureWidget image_widget;
    private Gtk.Button play_btn;
    private Gtk.Image play_icon;
    private Gtk.Image pause_icon;
    private PictureCollection collection;
    private Picture current_picture;
    private Gtk.Overlay overlay;
    private Gee.ArrayList<Gtk.Widget> overlay_widgets;
    //pointer tracking
    private bool cursor_hide = true;
    private bool playing = true;
    private double x_pointer_position = 0;
    private double y_pointer_position = 0;
    private double last_x_pointer_position = 0;
    private double last_y_pointer_position = 0;

    public SlideshowWindow (PictureCollection collection, int index_first_item) {

        Gdk.RGBA black = {0.0,0.0,0.0,0.95};
        this.set_background_color (black);
        this.overlay = new Gtk.Overlay ();
        image_widget = new Foto.Widgets.PictureWidget ();

        this.add(overlay);
        overlay.add(image_widget);

        //Next button
        var next_btn = buid_overlay_button ("slideshow-next");
        overlay.add_overlay(next_btn);
        next_btn.halign = Gtk.Align.END;
        next_btn.valign = Gtk.Align.CENTER;
        next_btn.margin_right = 12;
        next_btn.clicked.connect(action_go_next);

        //Previous button
        var prev_btn = buid_overlay_button ("slideshow-previous");
        overlay.add_overlay(prev_btn);
        prev_btn.halign = Gtk.Align.START;
        prev_btn.valign = Gtk.Align.CENTER;
        prev_btn.margin_left = 12;
        prev_btn.clicked.connect(action_go_previous);

        this.play_icon = new Gtk.Image.from_icon_name("slideshow-play", Gtk.IconSize.DIALOG);
        this.pause_icon = new Gtk.Image.from_icon_name("slideshow-pause", Gtk.IconSize.DIALOG);

        //Play button
        play_btn = buid_overlay_button ("slideshow-pause");
        overlay.add_overlay(play_btn);
        play_btn.halign = Gtk.Align.CENTER;
        play_btn.valign = Gtk.Align.END;
        play_btn.margin_bottom = 3;
        play_btn.clicked.connect(on_play_click);

        this.set_collection (collection, index_first_item);
        this.fullscreen ();
        this.show_all ();
        this.motion_notify_event.connect(on_pointer_motion);
        GLib.Timeout.add(1500,on_pointer_motion_stop);
        this.destroy.connect(on_destroy);
        this.play();

        image_widget.drag_action_begin.connect(() => {
            pause();
        });

        image_widget.scroll_event.connect(() => {
            pause();
            return false;
        });

    }

    //FIXME: Destructor method not working, only this works, why?
    private void on_destroy() {
        pause();
        cursor_hide = false;
        show_cursor ();
    }

    private Gtk.Button buid_overlay_button (string icon_name) {
        if(overlay_widgets == null)
            overlay_widgets = new Gee.ArrayList<Gtk.Widget>();
        var button = new Gtk.Button.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        button.get_style_context().remove_class ("button");
        Gdk.RGBA transparent = {0.0,0.0,0.0,0.0};
        button.override_background_color (Gtk.StateFlags.NORMAL, transparent);
        overlay_widgets.add(button);
        return button;
    }

    private void hide_overlay_widgets() {
        foreach(Gtk.Widget widget in overlay_widgets)
            widget.hide();
    }

    private void show_overlay_widgets() {
        foreach(Gtk.Widget widget in overlay_widgets)
            widget.show();
    }

    public void set_collection (PictureCollection collection, int index_first_item) {
        this.collection = collection;
        current_picture = collection.get (index_first_item);
        image_widget.set_image (current_picture.file_path);
    }

    public void set_picture (Picture picture) {
        current_picture = picture;
        image_widget.set_image (current_picture.file_path);
    }

    private void action_go_previous () {
        if(collection == null || collection.size<1)
            return;
        int index = collection.index_of (current_picture);
        debug("INDEX: %d", index);

        if((index-1) < 0)
            index = collection.size - 1;
        else
            index--;
        set_picture (collection.get(index));       
    }

    private void action_go_next () {
        if(collection == null || collection.size<1)
            return;
        int index = collection.index_of (current_picture);
        debug("INDEX: %d", index);

        if((index+1) >= collection.size)
            index = 0;
        else
            index++;
        set_picture (collection.get(index));
    }

    public void set_background_color (Gdk.RGBA color) {
        override_background_color (Gtk.StateFlags.NORMAL, color);
    }

    public void on_play_click() {
        if(playing)
            pause();
        else
            play();
    }

    public void play () {
        play_btn.set_image(pause_icon);
        playing = true;
        GLib.Timeout.add(5000, ()=>{
            if(!playing)
                return false;
            action_go_next();
            return playing;
        });
    }

    public void pause () {
        playing = false;
        play_btn.set_image(play_icon);
    }

    private bool on_pointer_motion (Gdk.EventMotion e) {
        show_cursor();
        show_overlay_widgets();
        update_cursor_position(e);
        return false;
    }

    private bool update_cursor_position (Gdk.EventMotion e) {
        x_pointer_position = e.x;
        y_pointer_position = e.y;
        return false;
    }

    private bool on_pointer_motion_stop() {
        if(!cursor_hide)
            return false;
        //if cursor hasn't moved
        if(last_x_pointer_position == x_pointer_position && last_y_pointer_position == y_pointer_position){
            hide_cursor();
            hide_overlay_widgets();
        } else {
            last_x_pointer_position = x_pointer_position;
            last_y_pointer_position = y_pointer_position;
        }
        return true;
    }

    private void set_cursor(Gdk.CursorType type){
        var cursor = new Gdk.Cursor(type);
        var window = overlay.get_parent_window();
        if(window != null)
            window.set_cursor(cursor);
    }

    private bool show_cursor(){
        this.set_cursor(Gdk.CursorType.ARROW);
        debug("Cursor show\n");
        return false;
    }

    private bool hide_cursor(){
        this.set_cursor(Gdk.CursorType.BLANK_CURSOR);
        debug("Cursor hide\n");
        return false;
    }

    public override bool key_press_event (Gdk.EventKey event) {
        switch(event.keyval) {
            case Gdk.Key.Left:
                pause();
                action_go_previous ();
                break;
            case Gdk.Key.Right:
                pause();
                action_go_next ();
                break;
            case Gdk.Key.Escape:
                this.destroy ();
                break;
            default:
                return false;
        }
        return true;
    }

}