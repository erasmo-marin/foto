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
using Granite.Drawing;

//TODO: Save cache images async
namespace Utils{

    public class PixbufUtils {

        public static Gdk.Pixbuf? render_box_shadow (Gdk.Pixbuf pixbuf,
                                                  int surface_size_w, int surface_size_h,
                                                  int shadow_size = 5, double alpha = 0.75) {

            int S_WIDTH = (surface_size_w > 0)? surface_size_w : pixbuf.width;
            int S_HEIGHT = (surface_size_h > 0)? surface_size_h : pixbuf.height;

            var buffer_surface = new Granite.Drawing.BufferSurface (S_WIDTH, S_HEIGHT);

            S_WIDTH -= 2 * shadow_size;
            S_HEIGHT -= 2 * shadow_size;

            buffer_surface.context.rectangle (shadow_size, shadow_size, S_WIDTH, S_HEIGHT);
            buffer_surface.context.set_source_rgba (0, 0, 0, alpha);
            buffer_surface.context.fill ();

            buffer_surface.fast_blur (2, 3);

            Gdk.cairo_set_source_pixbuf (buffer_surface.context,
                                         pixbuf.scale_simple (S_WIDTH, S_HEIGHT, Gdk.InterpType.HYPER),
                                         shadow_size,
                                         shadow_size);

            buffer_surface.context.paint ();

            return buffer_surface.load_to_pixbuf ();
        }

        public static Gdk.Pixbuf? render_drop_shadow (Pixbuf source, int shadow_size, double alpha_threshold, Granite.Drawing.Color shadow_color) {

            if(!source.has_alpha) return render_box_shadow (source, source.width,source.height);

            var copy = source.copy();

            var a = 0.0;
            
            uint8* dataPtr = copy.get_pixels ();
            double pixels = copy.height * copy.rowstride / copy.n_channels;
            double count = 0;            

            for (var i = 0; i < pixels; i++) {
                a = dataPtr [3];

                if(a >= alpha_threshold) {
                    dataPtr[0] = (uint8) shadow_color.B;
                    dataPtr[1] = (uint8) shadow_color.G;
                    dataPtr[2] = (uint8) shadow_color.R;
                    dataPtr[3] = (uint8) shadow_color.A;
                    count++;
                } else {
                    dataPtr[0] = 0;
                    dataPtr[1] = 0;
                    dataPtr[2] = 0;
                    dataPtr[3] = 0;
                }
                dataPtr += copy.n_channels;
            }

            if (count == 0)
                return render_box_shadow (source, source.width,source.height);

            var buffer_surface = new Granite.Drawing.BufferSurface (copy.width, copy.height);
            copy = copy.scale_simple (copy.width-4*shadow_size, copy.height-4*shadow_size, Gdk.InterpType.HYPER);
            Gdk.cairo_set_source_pixbuf (buffer_surface.context, copy, 2*shadow_size, 2*shadow_size);
            buffer_surface.context.paint ();
            buffer_surface.fast_blur (shadow_size, 3);
            Gdk.cairo_set_source_pixbuf (buffer_surface.context, 
                                         source.scale_simple (source.width-4*shadow_size, source.height-4*shadow_size, Gdk.InterpType.BILINEAR), 
                                         2*shadow_size, 2*shadow_size);
            buffer_surface.context.paint ();
            return buffer_surface.load_to_pixbuf ();
        }


        //resize a pixbuf preserving the aspect ratio of original pixbuf
        private Gdk.Pixbuf resize_pixbuf(Pixbuf pixbuf, int width, int height) {

            double rf1, rf2;
            Pixbuf result = pixbuf.copy();

            rf1 = (double)width/(double)pixbuf.get_width();
            rf2 = (double)height/(double)pixbuf.get_height();

            int posibility1 = (int)(pixbuf.get_height() * rf1);
            int posibility2 = (int)(pixbuf.get_width() * rf2);

            if(posibility1 <= height) {
                  return result.scale_simple(width,posibility1, InterpType.NEAREST);
            } else {
                  return result.scale_simple(posibility2,height, InterpType.NEAREST);
            }
        }

    }
}