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

using GLib;
using Gdk;

public abstract class PhotoDriver {

    public Picture file;


    public PhotoDriver (Picture file) {
        this.file = file;
    }

    public abstract Pixbuf read_photo();
    public abstract Pixbuf read_scaled(int width, int height, bool conserve_aspect_ratio);
    public abstract PhotoMetadata read_metadata();
    public abstract void write_metadata(PhotoMetadata metadata);
    public abstract bool can_write_image();
    public abstract bool can_write_metadata();

}