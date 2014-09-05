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

//TODO: Inverse search

/* PictureSorter allows to set the sort flags.
 * The sort function will sort the pictures
 * according to these flags.
 */
public class PictureSorter {

    public enum SortMode {
        ALPHABETICALLY,
        BY_IMPORT_DATE,
        BY_RATING;
    }

    SortMode[] sort_priorities;

    //search flags
    public bool alphabetically = true;
    public bool by_import_date = false; //newest first
    public bool by_rating = false; //more rating first

    //the inverted flags allow to change the order if the search flag is setted to true
    public bool alphabetically_inverted = false;
    public bool by_import_date_inverted = false; //older first
    public bool by_rating_inverted = false; //less rating first


    public PictureSorter(bool alphabetically, bool by_import_date, bool by_rating) {
        this.alphabetically = alphabetically;
        this.by_import_date = by_import_date;
        this.by_rating = by_rating;
         sort_priorities += SortMode.BY_RATING;
         sort_priorities += SortMode.BY_IMPORT_DATE;
         sort_priorities += SortMode.ALPHABETICALLY;
    }

    public void set_sort_flags(bool alphabetically, bool by_import_date, bool by_rating) {
        this.alphabetically = alphabetically;
        this.by_import_date = by_import_date;
        this.by_rating = by_rating;
    }

    public void set_sort_priorities(SortMode first, SortMode second, SortMode third) {
            sort_priorities[0] = first;
            sort_priorities[1] = second;
            sort_priorities[2] = third;
    }

    //< 0 if item1 should be before item2, 0 if they are equal and > 0 otherwise
    //default priorities are 1)alphabetically, 2)import_date, 3) rating
    public int sort(Picture picture1, Picture picture2) {

        int sv; 

        for(int i=0; i<3; i++) {

            SortMode mode = sort_priorities[i];

            if(alphabetically && mode == SortMode.ALPHABETICALLY) {
                GLib.File file1 = GLib.File.new_for_commandline_arg (picture1.file_path);
                GLib.File file2 = GLib.File.new_for_commandline_arg (picture2.file_path);
                sv = alphabetically_sort(file1.get_basename(), file2.get_basename());

                if( sv != 0 )
                    return sv;
            }
            
            if (by_import_date && mode == SortMode.BY_IMPORT_DATE) {
                sv = int_sort(picture1.import_date, picture2.import_date);

                if( sv != 0 )
                    return sv;
            }

            if (by_rating && mode == SortMode.BY_RATING) {
                sv = int_sort((int)picture1.rating, (int)picture2.rating);

                if( sv != 0 )
                    return sv;
            }
        }

        return 0;
    }

    private int alphabetically_sort(string str1, string str2) {
        return str1.ascii_casecmp (str2);
    }

    //more to less
    private int int_sort(int number1, int number2) {
        return (number2 - number1);
    }

}