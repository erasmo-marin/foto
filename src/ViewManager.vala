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

public enum PageType {

    WELCOME_PAGE,
    VIEWER_PAGE,
    LIBRARY_PAGE,
    LAST_IMPORTED_PAGE,
    ALBUM_PAGE,
    TAG_PAGE,
    MAP_PAGE;

    public string to_string() {
        switch (this) {
            case WELCOME_PAGE:
                return "WelcomePage";
            case VIEWER_PAGE:
                return "ViewerPage";
            case LIBRARY_PAGE:
                return "LibraryPage";
            case LAST_IMPORTED_PAGE:
                return "LastImportedPage";
            case TAG_PAGE:
                return "TagPage";
            case ALBUM_PAGE:
                return "AlbumPage";
            case MAP_PAGE:
                return "MapPage";
            default:
                return "Unknown";
        }
    }

    public static PageType parse(string str) {
        switch (str) {
            case "WelcomePage":
                return PageType.WELCOME_PAGE;
            case "ViewerPage":
                return PageType.VIEWER_PAGE;
            case "LibraryPage":
                return PageType.LIBRARY_PAGE;
            case "LastImportedPage":
                return PageType.LAST_IMPORTED_PAGE;
            case "TagPage":
                return PageType.TAG_PAGE;
            case "AlbumPage":
                return PageType.ALBUM_PAGE;
            case "MapPage":
                return PageType.MAP_PAGE;
            default:
                assert_not_reached();
        }
    }

}


public class ViewManager {

    private static Gee.ArrayList<Page> pages;
    private PageContainer container;

    public ViewManager(PageContainer container) {
        pages = new Gee.ArrayList<Page>();
        this.container = container;
    }


    public Page? get_page(PageType page_type) {

        Page page = check_page(page_type);
        if(page != null)
            return page;

        return instantiate(page_type);
    }

    private Page instantiate(PageType page_type) {

        switch (page_type) {
            case PageType.WELCOME_PAGE:
                Page page = new WelcomePage(container);
                register_page(page);
                return page;
            case PageType.VIEWER_PAGE:
                Page page = new ViewerPage(container);
                register_page(page);
                return page;
            case PageType.LIBRARY_PAGE:
                Page page = new LibraryPage(container);
                register_page(page);
                return page;
            case PageType.LAST_IMPORTED_PAGE:
                Page page = new LastImportedPage(container);
                register_page(page);
                return page;
            case PageType.TAG_PAGE:
                Page page = new TagPage(container);
                register_page(page);
                return page;
            case PageType.ALBUM_PAGE:
                Page page = new AlbumPage(container);
                register_page(page);
                return page;
            case PageType.MAP_PAGE:
                Page page = new MapPage(container);
                register_page(page);
                return page;           
            default:
                assert_not_reached();
        }
    }


    private void register_page (Page page) {
       pages.add(page);
    }

    private Page? check_page(PageType page_type) {
        foreach (Page page in pages) {
            if (page.page_name == page_type.to_string())
                return page;
        }
        return null;
    }
}