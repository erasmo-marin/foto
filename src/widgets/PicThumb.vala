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

using GLib.Math;
using Gdk;
using Gtk;
using Cairo;
using Granite.Drawing;
using Utils;


namespace Foto.Widgets{

public enum IconSize {
    SMALL,
    NORMAL,
    BIG,
    HUGE;

    public int to_int() {
        switch(this) {
            case SMALL:
                return 100;
            case NORMAL:
                return 150;
            case BIG:
                return 200;
            case HUGE:
                return 250;
            default:
                assert_not_reached();
        }
    }
}


//A widget that displays a photo
private class PicThumb :  CollectionItem {

    enum Target {
        INT32,
        STRING,
        ROOTWIN
    }

    /* datatype (string), restrictions on DnD (Gtk.TargetFlags), datatype (int) */
    const TargetEntry[] target_list = {
        { "INTEGER",    0, Target.INT32 },
        { "STRING",     0, Target.STRING },
        { "text/plain", 0, Target.STRING },
        { "application/x-rootwindow-drop", 0, Target.ROOTWIN }
    };

    private IconSize size;
    private Picture picture;
    private Pixbuf thumb;
    //the white border size in pixels
    private int border_size = 3;
    //the shadow size arround the image in pixels
    private int shadow_size = 3;
    private double scale = 0.6;


    //stars
    private static Pixbuf star_active;
    private static Pixbuf star_inactive;
    private static Pixbuf star_prelight;
    private Gdk.Rectangle stars_box;

    //signals   
    public virtual signal void icon_clicked_event(){
        debug("Icon clicked event");
    }

    public virtual signal void icon_right_clicked_event(){
        debug("Icon right clicked event");
    }

    public virtual signal void icon_double_clicked_event(){
        debug("Icon double clicked event");
    }

    public PicThumb.from_picture (CollectionPage page, Picture picture, IconSize size) {
        base(page);
        this.size = size;
        this.picture = picture;
        render_thumb.begin();
        init_ui();
    }
   
    public PicThumb(CollectionPage page) {
        base(page);
        init_ui();
    }

    public Picture get_picture() {
        return this.picture;
    }

    private void init_ui () {


        //try to load icons from theme
        if(star_active == null || star_inactive == null || star_prelight == null) {
            try {
                Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
                star_active = icon_theme.load_icon ("starred", 16, IconLookupFlags.FORCE_SIZE);
                star_inactive = icon_theme.load_icon ("non-starred-symbolic", 16, IconLookupFlags.FORCE_SIZE);
                star_prelight = icon_theme.load_icon ("non-starred-grey", 16, IconLookupFlags.FORCE_SIZE);
            } catch (GLib.Error err) {
     	        warning("Getting icons from theme failed, using fallback mode.");
                //fallback mode if no icons are found
                star_active = Utils.IconFactory.get_icon(Utils.IconFactory.IconType.STAR_ACTIVE);
                star_inactive =  Utils.IconFactory.get_icon(Utils.IconFactory.IconType.STAR_INACTIVE);
                star_prelight = Utils.IconFactory.get_icon(Utils.IconFactory.IconType.STAR_PRELIGHT);
            }
        }

        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                    | Gdk.EventMask.BUTTON_RELEASE_MASK 
                    | Gdk.EventMask.LEAVE_NOTIFY_MASK 
                    | Gdk.EventMask.ENTER_NOTIFY_MASK );

        set_vexpand(false);
        set_hexpand(false);
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;

        //returning true instead false because problem in FlowBox way of handling user clicks
        button_press_event.connect((event) => {

            if (event.button == 3) {
                icon_right_clicked_event();
            } else if (event.button == 1) {

                if(event.type == Gdk.EventType.@2BUTTON_PRESS) {
                    icon_double_clicked_event();
                }
                if(event.type == Gdk.EventType.@3BUTTON_PRESS)
                    return true;
                else {
                    int star_clicked = get_clicked_star(event);
                    if(star_clicked != -1) {
                        is_selected = true;
                        if(picture.rating == star_clicked)
                            picture.rating = 0;
                        else
                            picture.rating = star_clicked;
                        queue_draw();
                        return true;
                    }
        	        icon_clicked_event();
                }
            }
            queue_draw();
            return true;
        });


        enter_notify_event.connect(() => {
            this.set_state_flags(this.get_state_flags() | StateFlags.PRELIGHT,true);
            queue_draw();
            return false;
        });

        leave_notify_event.connect(() => {
            if((this.get_state_flags() & StateFlags.SELECTED) == StateFlags.SELECTED)
                return false;
            this.set_state_flags(StateFlags.NORMAL,true);
            queue_draw();
            return false;
        });

        this.get_style_context().remove_class("gtk-image");
        Gtk.drag_source_set (this, ModifierType.BUTTON1_MASK , target_list, DragAction.COPY);
    }
	
    public override bool draw (Cairo.Context cr) {
        if(thumb == null)
            return false;

        cr.save();
        cr.scale(this.scale, this.scale);
        cairo_set_source_pixbuf (cr, thumb, 0, 0);
        cr.paint();
        cr.restore();

        //only show stars in prelight mode and if rating is > 0
        if(picture.rating == 0 && (this.get_state_flags() & StateFlags.PRELIGHT) != StateFlags.PRELIGHT)
            return false;

        //draw black background for stars
        int y = (int)(scale*(thumb.get_height() - border_size - 2*shadow_size) - star_active.get_height());
        int x = (int)(scale*(border_size + 2*shadow_size));
        cr.set_source_rgba(0,0,0,0.8);
        cr.rectangle (x,y,star_active.get_width()*5,star_active.get_height());

        //only show stars if there is space for drawing
        if((star_active.get_width()*5) > (thumb.get_width()*scale))
            return false;

        cr.fill();

        //draw the stars
        for(int i=0; i<(int)picture.rating; i++) {
            cairo_set_source_pixbuf (cr, star_active, x+(i*star_active.get_width()), y);
            cr.paint();
        }
        for(int i=(int)picture.rating; i<5; i++) {
            cairo_set_source_pixbuf (cr, star_inactive, x+(i*star_active.get_width()), y);
            cr.paint();
        }
        //update the stars region
        stars_box = {x,y,star_active.get_width()*5, star_active.get_height()};

        return false;
    }

    //return wich star was clicked, if no star was clicked, it returns -1
    private int get_clicked_star(EventButton event) {
        if(event.x > stars_box.x && event.x < (stars_box.x + stars_box.width) &&
           event.y > stars_box.y && event.y < (stars_box.y + stars_box.height) ) {
            return (int)((event.x - stars_box.x)/(stars_box.width/5)) + 1;
        }
        return -1;
    }

    public void set_scale(double scale) {
        this.scale = scale;
        this.set_size_request((int)(thumb.get_width()*scale), (int)(thumb.get_height()*scale));
        queue_draw();
    }

    private async void render_thumb() {

        thumb = Cache.get_cached_image (picture.file_path);
        if(thumb != null) {
            this.set_size_request((int)(thumb.get_width()*scale), (int)(thumb.get_height()*scale));
            queue_draw();
            return;
        }
        Pixbuf image;
        GLib.File file = GLib.File.new_for_commandline_arg (picture.file_path);

	    try {
	        GLib.InputStream stream = yield file.read_async ();
            image = yield new Pixbuf.from_stream_at_scale_async (stream,size.to_int() - 2*border_size,
                                                                  size.to_int()-2*border_size,true);
	    } catch ( GLib.Error e ) {
	        warning (e.message);
            return;
	    }

        //White background
        var buffer_surface = new Granite.Drawing.BufferSurface (image.get_width() + 2*border_size, 
                                                                 image.get_height() + 2*border_size);
        buffer_surface.context.set_source_rgba (1,1,1,1);
        buffer_surface.context.rectangle (0, 0, image.get_width() + 2*border_size, 
                                                image.get_height() + 2*border_size);

        buffer_surface.context.fill ();
        //draw the image in the center
        Gdk.cairo_set_source_pixbuf (buffer_surface.context, image, border_size, border_size);
        buffer_surface.context.paint();

        image = buffer_surface.load_to_pixbuf ();
        buffer_surface.clear();
        var shadow_color = new Granite.Drawing.Color(0,0,0,190);
        this.thumb = PixbufUtils.render_drop_shadow (image, shadow_size, 200, shadow_color);
        Cache.cache_image_pixbuf(thumb, picture.file_path);
        this.set_size_request((int)(thumb.get_width()*scale), (int)(thumb.get_height()*scale));
        queue_draw();
    }
}
}