// TEMPORARY
class Blog {
    static blogList = new Map(); 

    constructor(title, caption, content, date, displayPic, picture) {
        this.title = title;
        this.caption = caption;
        this.content = content;
        this.date = date;
        this.displayPic = displayPic;
        this.picture = picture;
    }

    addBlog() {
        blogList.set(this.title, this);
    }

    editBlog(title, newContent) {
        blogList.get(title).content = newContent;
    }
}