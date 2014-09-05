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

namespace Foto.Widgets {

public class Rating : Gtk.DrawingArea {

    private static Pixbuf star_active;
    private static Pixbuf star_inactive;
    private int star_width = 0;
    private int star_height = 0;
    private uint rating = 0;
    public signal void rating_changed(uint rating);


    public Rating (uint rating) {
        if(rating > 5) {
            warning("Rating value may not be greater than 5, rating value will be setted to 5");
            rating = 5;
        }

        //try to load icons from theme
        if(star_active == null || star_inactive == null) {
            try {
                Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
                star_active = icon_theme.load_icon ("starred", 16, IconLookupFlags.FORCE_SIZE);
                star_inactive = icon_theme.load_icon ("non-starred", 16, IconLookupFlags.FORCE_SIZE);
            } catch (GLib.Error err) {
     	        warning("Getting icons from theme failed, using fallback mode.");
                //fallback mode if no icons are found
                star_active = Utils.IconFactory.get_icon(Utils.IconFactory.IconType.STAR_ACTIVE);
                star_inactive =  Utils.IconFactory.get_icon(Utils.IconFactory.IconType.STAR_INACTIVE);
            }
        }

        this.rating = rating;
        this.star_width = star_active.get_width();
        this.star_height = star_active.get_height();

        this.height_request = star_height;
        this.width_request = star_width * 5;
        this.margin = 0;

        this.set_hexpand(true);
        this.set_vexpand(true);

        add_events (  Gdk.EventMask.BUTTON_PRESS_MASK
                    | Gdk.EventMask.BUTTON_RELEASE_MASK);

        button_release_event.connect(on_star_clicked);

    }

    public void set_rating (uint rating) {
        if(rating <=5){
            this.rating = rating;
            this.queue_draw();
        } else {
            warning("Rating value may not be greater than 5, rating value will be setted to 5");
            rating = 5;
        }
    }

    private bool on_star_clicked (EventButton event) {
        
        uint new_rating = (uint)(event.x/16) + 1;
        uint old_rating = rating;

        if(new_rating == 1) { //if rating is 1, we toggle the star
            if(rating == 1)
                rating = 0;
            else
                rating = 1;
        }
        else {
            rating = new_rating;
        }

        if(old_rating != rating){ //draw and emmit signal only if value changed
            queue_draw ();
            rating_changed(rating); 
        }
        return false;
    }    


    //DRAW
    public override bool draw (Cairo.Context cr) {

        uint i;
        int margin_x = 0;

        
        for(i=0; i<rating; i++) {
            Gdk.cairo_set_source_pixbuf(cr,star_active, margin_x, 0);
            cr.paint();
            margin_x+=star_width;
        }

        for(i=rating; i<5; i++) {
            Gdk.cairo_set_source_pixbuf(cr,star_inactive, margin_x, 0);
            cr.paint();
            margin_x+=star_width;
        }

        return false;
    }


}
}