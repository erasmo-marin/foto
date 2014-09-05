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

using Foto.Widgets;
using Foto.Dialogs;

public class LastImportedPage : CollectionPage {

    private PictureCollection collection;

    private Gtk.ToolButton add_to_album_btn;
    private Gtk.ToolButton remove_selection_btn;
    private Gtk.ToolButton unselect_btn;

    public LastImportedPage(PageContainer container) {
        base(PageType.LAST_IMPORTED_PAGE.to_string(), container);
        sorter = new PictureSorter(true, false, true);
        filter = new PictureFilter();
        sorter.set_sort_priorities(PictureSorter.SortMode.ALPHABETICALLY,
                                   PictureSorter.SortMode.BY_RATING,
                                   PictureSorter.SortMode.BY_IMPORT_DATE);
        update_last_import();
        build_sort_bar ();
    }

    private void update_last_import() {

        remove_all_items();

        var picdao = PictureDAO.get_instance();
        collection = picdao.get_last_import();

        foreach(Picture pic in collection) {
            var thumb = new PicThumb.from_picture (this, pic, IconSize.HUGE);
            thumb.icon_double_clicked_event.connect(() => {
                ViewerPage page = (container.get_page(PageType.VIEWER_PAGE) as ViewerPage);
                page.set_collection(collection, collection.index_of(pic));
                container.switch_to_page(PageType.VIEWER_PAGE);
            });
            add_item(thumb);
            thumb.zoom_request.connect((val)=>{
                thumb.set_scale(val);
                debug("Resize item at %f:", val);
            });
        }

    }

    private void build_toolbars_extras() {
        add_to_album_btn = new Gtk.ToolButton(null, _("Add to album..."));
        remove_selection_btn = new Gtk.ToolButton(null, _("Remove"));
        unselect_btn = new Gtk.ToolButton(null, _("Unselect"));

        add_to_album_btn.clicked.connect(()=>{
            var collection = new PictureCollection();
            foreach(CollectionItem item in get_selected_items()) {
                collection.add((item as PicThumb).get_picture());
            }
            var popover = new AddToAlbumDialog(collection, add_to_album_btn);
            popover.show();
        });

        unselect_btn.clicked.connect(()=>{
            box.unselect_all();
        });

        left_toolbar.add(add_to_album_btn);
        left_toolbar.add(remove_selection_btn);
        left_toolbar.add(unselect_btn);
    }


    public void build_sort_bar () {

        var alphabetically_btn = sort_bar.add_sort_button(_("alphabetically"));
        var rating_btn = sort_bar.add_sort_button(_("rating"));

        alphabetically_btn.clicked.connect(sort_alphabetically);
        rating_btn.clicked.connect(sort_by_rating);
    }


    private void sort_alphabetically() {
        sorter.set_sort_priorities(PictureSorter.SortMode.ALPHABETICALLY,
                                   PictureSorter.SortMode.BY_IMPORT_DATE, 
                                   PictureSorter.SortMode.BY_RATING);
        invalidate_sort();
    }


    private void sort_by_rating() {
        sorter.set_sort_priorities(PictureSorter.SortMode.BY_RATING,
                                   PictureSorter.SortMode.BY_IMPORT_DATE,
                                   PictureSorter.SortMode.ALPHABETICALLY);
        invalidate_sort();
    }


    public override bool filter_items(CollectionItem item) {
        return filter.filter_for_string((item as PicThumb).get_picture(), search_bar.get_text());
    }

    public override int sort_items(CollectionItem item1, CollectionItem item2) {
        return sorter.sort((item1 as PicThumb).get_picture(), (item2 as PicThumb).get_picture());
    }



}