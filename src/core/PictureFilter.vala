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

public class PictureFilter {

    public enum FilterMode {
        BY_NAME,
        BY_RATING,
        BY_COMMENT,
        ALL;
    }

    public bool filter_for_string(Picture picture, string? search_string) {

        if(search_string == null)
            return true;

        GLib.File file = GLib.File.new_for_commandline_arg (picture.file_path);

        if(file.get_basename().contains(search_string) || (picture.comment != null && picture.comment.contains(search_string)))
            return true;

        foreach(string tag in picture.tags) {
            if(tag != null && tag.contains(search_string)) {
                return true;
            }
        }

        return false;

    }


}