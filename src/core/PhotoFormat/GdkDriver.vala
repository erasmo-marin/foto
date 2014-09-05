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

public abstract class GdkDriver : PhotoDriver {

    public GdkDriver (Picture file) {
        base(file);
    }

    public Pixbuf read_photo() {
        return new Pixbuf.from_file(file.file_path);
    }

    public Pixbuf read_scaled(int width, int height, bool conserve_aspect_ratio) {
        return new Pixbuf.from_file_at_scale(file.file_path, width, height, conserve_aspect_ratio);
    }

    public PhotoMetadata read_metadata(){
        return new PhotoMetadata(file);
    }

    public void write_metadata(PhotoMetadata metadata) {

    }

    public bool can_write_image() {
        return false;
    }
    public bool can_write_metadata() {
        return false;
    }

}