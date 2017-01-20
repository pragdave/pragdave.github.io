// if the window hash matches a media item on the page, promote it
// to the top


function move_hashed_content_to_top() {
    var hash = window.location.hash;
    if (hash) {
        var $small_element = $(hash);
        if ($small_element) {
            $small_element.hide();
            var $showcase = $(".showcase");
            var $holder = $showcase.find("#holder");
            $holder.html($small_element.html());
            $holder.addClass($small_element.attr("class"));
            $showcase.show(500);
            $(window).scrollTop(0);
        }
    }
}

$(function () {
    if ($(".speak")) {
        move_hashed_content_to_top();

        $(".card-columns").on("click", "figcaption", function(ev) {
            ev.preventDefault();
            let new_hash = this.parentNode.id;
            window.location.hash = new_hash;
            $("figure").show(200);
            move_hashed_content_to_top();
        });
    }
});
