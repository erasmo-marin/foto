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

using Utils;

namespace Foto.Widgets {

    public class ZoomSlider : Gtk.ToolItem {

        private Gtk.Scale slider;
        private double start_val = 0.1;
        private double end_val = 2;
        private double zoom_step = 0.1;
        
        public signal void zoom_changed(double val);

        public ZoomSlider() {

            Gtk.Box zoom_group = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

            Gtk.Image zoom_out = new Gtk.Image.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            zoom_out.tooltip_text = _("Zoom out");
            Gtk.EventBox zoom_out_box = new Gtk.EventBox();
            zoom_out_box.set_above_child(true);
            zoom_out_box.set_visible_window(false);
            zoom_out_box.add(zoom_out);
            
            zoom_group.pack_start(zoom_out_box, false, false, 0);

            slider = new Gtk.Scale.with_range(Gtk.Orientation.HORIZONTAL,start_val, end_val,zoom_step);
            slider.set_increments (zoom_step, zoom_step);
            slider.set_draw_value(false);
            slider.set_size_request(120, -1);
            slider.set_can_focus (false);

            zoom_group.pack_start(slider, false, false, 0);

            Gtk.Image zoom_in = new Gtk.Image.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            zoom_in.tooltip_text = _("Zoom in");
            Gtk.EventBox zoom_in_box = new Gtk.EventBox();
            zoom_in_box.set_above_child(true);
            zoom_in_box.set_visible_window(false);
            zoom_in_box.add(zoom_in);

            zoom_group.pack_start(zoom_in_box, false, false, 0);
            add(zoom_group);

            zoom_in_box.button_press_event.connect(on_zoom_in);
            zoom_out_box.button_press_event.connect(on_zoom_out);
            slider.value_changed.connect(() =>{
                zoom_changed(slider.get_value());
            });
        }

        private bool on_zoom_in() {
            slider.set_value (slider.get_value()+zoom_step);
            return true;
        }
        private bool on_zoom_out() {
            slider.set_value (slider.get_value()-zoom_step);
            return true;
        }

        public void set_value(double val){
            slider.set_value(val);
        }

        public void set_range (double min_value, double max_value) {
            start_val = min_value;
            end_val = max_value;
            slider.set_range (min_value, max_value);
        }

        public void set_zoom_step (double step) {
            zoom_step = step;
        }

        public void add_mark_at(double val) {
            slider.add_mark (val, Gtk.PositionType.BOTTOM, null);
            slider.add_mark (val, Gtk.PositionType.TOP, null);
        }


    }
}