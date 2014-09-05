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

public class Sidebar : Gtk.Box {

    Granite.Widgets.SourceList sourcelist;
    Gtk.Toolbar bottom_toolbar;
    Foto.Dialogs.AlbumDialog album_dialog;
    PageContainer page_container;
    Gee.ArrayList<Granite.Widgets.SourceList.Item> items;


    public class SidebarItem : Granite.Widgets.SourceList.Item {

        public PageType page_type;

        public SidebarItem(string label, PageType page_type, Gee.ArrayList<Granite.Widgets.SourceList.Item> items) {
            base(label);
            this.page_type = page_type;
            items.add(this);
        }
    }


    public Sidebar(PageContainer page_container) {

        GLib.Object(orientation: Gtk.Orientation.VERTICAL);

        this.page_container = page_container;
        this.items = new Gee.ArrayList<Granite.Widgets.SourceList.Item>();
        this.set_can_focus(false);

        //Bottom toolbar
        bottom_toolbar = new Gtk.Toolbar();
        var add_button = new Gtk.ToolButton(new Gtk.Image.from_icon_name("list-add-symbolic", Gtk.IconSize.MENU),"");
        bottom_toolbar.icon_size = Gtk.IconSize.MENU;
        bottom_toolbar.get_style_context().add_class("inline-toolbar");
        bottom_toolbar.insert(add_button,-1);

        //popopver and actions
        var builder = new Gtk.Builder();
        builder.add_from_string(add_menu_string, -1);
        GLib.MenuModel add_menu_model = (GLib.MenuModel) builder.get_object("add-menu");

        Gtk.Popover popover = new Gtk.Popover.from_model(add_button, add_menu_model);

        var action_group = new GLib.SimpleActionGroup();

        var action_new_album = new SimpleAction ("new-album", null);
        action_group.add_action(action_new_album);
        var action_import = new SimpleAction ("import", null);
        action_group.add_action(action_import);

        action_new_album.activate.connect(()=>{new_album_activated();});
        action_import.activate.connect(()=>{import_activated();});

        popover.insert_action_group("local", action_group);

        add_button.clicked.connect(() => {
            popover.show_all();
        });

        //Sourcelist categories
        var library_category = new Granite.Widgets.SourceList.ExpandableItem(_("Library"));
        var album_category = new Granite.Widgets.SourceList.ExpandableItem(_("Albums"));
        var tag_category = new Granite.Widgets.SourceList.ExpandableItem(_("Tags"));


        //library
        var pictures_item = new SidebarItem(_("Photos"), PageType.LIBRARY_PAGE, items);
        var icon = GLib.Icon.new_for_string("foto-pictures-item");
        pictures_item.icon = icon;

        var last_imported_item = new SidebarItem(_("Last imported"), PageType.LAST_IMPORTED_PAGE, items);
        icon = GLib.Icon.new_for_string("foto-last-import-item");
        last_imported_item.icon = icon;

        //Uncommento to test maps
        /*var map_item = new SidebarItem(_("Places"), PageType.MAP_PAGE, items);
        icon = GLib.Icon.new_for_string("foto-places-item");
        map_item.icon = icon;*/

        library_category.add(pictures_item);
        library_category.add(last_imported_item);
        //library_category.add(map_item);

        //albums
        var albumdao = AlbumDAO.get_instance ();
        var album_collection = albumdao.get_all();

        albumdao.album_inserted.connect((album)=>{
            var album_item = new SidebarItem(album.album_name, PageType.ALBUM_PAGE, items);
            icon = Foto.Widgets.ColorRow.get_color_dot_from_hex(Foto.Widgets.RowPalette.unserialize((int)album.color), 16, 16);
            album_item.icon = icon;
            album_category.add(album_item);
        });

        foreach (Album album in album_collection) {
            var album_item = new SidebarItem(album.album_name, PageType.ALBUM_PAGE, items);
            icon = Foto.Widgets.ColorRow.get_color_dot_from_hex(Foto.Widgets.RowPalette.unserialize((int)album.color), 16, 16);
            album_item.icon = icon;
            album_category.add(album_item);
        }

        //tags
        var tagdao = TagDAO.get_instance();
        var tag_collection = tagdao.get_all();

        foreach (Tag tag in tag_collection) {
            var tag_item = new SidebarItem(tag.tag, PageType.TAG_PAGE, items);
            var tag_icon = GLib.Icon.new_for_string("foto-tag-item");
            tag_item.icon = tag_icon;
            tag_category.add(tag_item);
        }

        //root
        sourcelist = new Granite.Widgets.SourceList();
        sourcelist.root.add(library_category);
        sourcelist.root.add(album_category);
        sourcelist.root.add(tag_category);
        sourcelist.width_request = 150;

        library_category.expanded = true;
        album_category.expanded = true;
        tag_category.expanded = true;

        this.pack_start(sourcelist, true, true, 0);
        this.pack_end(bottom_toolbar, false, false, 0);

        this.sourcelist.item_selected.connect(on_item_selected);

        //TODO: Old code was buggy
        page_container.page_switched.connect((last_page, current_page)=>{

        });
    }

    private void on_item_selected(Granite.Widgets.SourceList.Item? item) {

        debug("Item selected");
        if(item is SidebarItem) {
            if((item as SidebarItem).page_type == PageType.TAG_PAGE) {
                (page_container.get_page(PageType.TAG_PAGE) as TagPage).set_tag(new Tag.with_values( null,item.name));
            } else if ((item as SidebarItem).page_type == PageType.ALBUM_PAGE) {
                debug("Album page request");
                AlbumPage page = (page_container.get_page(PageType.ALBUM_PAGE) as AlbumPage);
                page.set_album(AlbumDAO.get_instance().get_by_name(item.name));
            }
            debug("Switching to page from sidebar");
            page_container.switch_to_page((item as SidebarItem).page_type);
        }
    }

    public void new_album_activated() {
        if(album_dialog ==  null) {
            album_dialog = new Foto.Dialogs.AlbumDialog( null);
            album_dialog.destroy.connect(() =>{
                album_dialog =  null;
            });
        }
    }

    public void import_activated() {
        page_container.switch_to_page(PageType.WELCOME_PAGE);
    }

    const string add_menu_string ="""<interface>
                                        <menu id='add-menu'>
                                            <item>
                                                <attribute name='label' translatable='yes'>Create _New Album</attribute>
                                                <attribute name='action'>local.new-album</attribute>
                                            </item>
                                            <item>
                                                <attribute name='label' translatable='yes'>_Import photos to Library</attribute>
                                                <attribute name='action'>local.import</attribute>
                                            </item>
                                        </menu>
                                    </interface>""";
}