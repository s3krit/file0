$(function() {  //run when the DOM is ready
  const fileInput = document.getElementById("fileInput");

  window.addEventListener('paste', e => {
    fileInput.files = e.clipboardData.files;
  });
  
  $(".btn-spinz").click(function() {      //use a class, since your ID gets mangled
    $(".spinz").addClass("fa-refresh");   //add the class to the clicked element
    $(".spinz").addClass("fa-spin");      //add the class to the clicked element
    $i = $(".spinz")
    $(this).text("Uploading... ");
    $(this).append($i);
  });
});
