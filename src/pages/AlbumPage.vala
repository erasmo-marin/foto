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

public class AlbumPage : CollectionPage {

    private Album album;
    private PictureCollection collection;

    private Gtk.ToolButton add_to_album_btn;
    private Gtk.ToolButton remove_selection_btn;
    private Gtk.ToolButton unselect_btn;

    public AlbumPage(PageContainer container) {
        base(PageType.ALBUM_PAGE.to_string(), container);
        sorter = new PictureSorter(true, true, true);
        filter = new PictureFilter();
        sorter.set_sort_priorities(PictureSorter.SortMode.BY_IMPORT_DATE,
                                   PictureSorter.SortMode.ALPHABETICALLY,
                                   PictureSorter.SortMode.BY_RATING);
        build_sort_bar();
    }

    public void set_album(Album? album) {
        debug("setting album");
        if(album == null)
            return;
        if(this.album != null && album.id == this.album.id)
            return;

        this.album = album;
        remove_all_items();
        debug("loading album thumbs");
        load_thumbs();
    }


    public void load_thumbs () {

        PictureDAO picdao = PictureDAO.get_instance();
        collection = picdao.get_for_album(album);

        foreach(Picture pic in collection) {
            var thumb = new PicThumb.from_picture (this, pic, IconSize.NORMAL);
            thumb.icon_double_clicked_event.connect(() => {
                print("Item clicked\n");
                ViewerPage page = (container.get_page(PageType.VIEWER_PAGE) as ViewerPage);
                page.set_collection(collection, collection.index_of(pic));
                container.switch_to_page(PageType.VIEWER_PAGE);
            });
            add_item(thumb);
        }
        return;
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
        var import_date_btn = sort_bar.add_sort_button(_("import date"));
        var rating_btn = sort_bar.add_sort_button(_("rating"));

        alphabetically_btn.clicked.connect(sort_alphabetically);
        import_date_btn.clicked.connect(sort_by_import_date);
        rating_btn.clicked.connect(sort_by_rating);
    }


    private void sort_alphabetically() {
        sorter.set_sort_priorities(PictureSorter.SortMode.ALPHABETICALLY,
                                   PictureSorter.SortMode.BY_IMPORT_DATE, 
                                   PictureSorter.SortMode.BY_RATING);
        invalidate_sort();
    }

    private void sort_by_import_date() {
        sorter.set_sort_priorities(PictureSorter.SortMode.BY_IMPORT_DATE,
                                   PictureSorter.SortMode.ALPHABETICALLY,
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