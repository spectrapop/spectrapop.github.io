<script>
document.addEventListener("DOMContentLoaded", function () {

  const toc = document.getElementById("TOC");

  if (toc) {

    const visitorBox = document.createElement("div");

    visitorBox.innerHTML = `
      <div style="
        margin-top: 35px;
        padding-top: 20px;
        border-top: 1px solid #dee2e6;
        text-align: center;
      ">
        <div style="
          font-size: 0.85rem;
          font-weight: 600;
          margin-bottom: 10px;
          opacity: 0.8;
        ">       
        </div>
      </div>
    `;

    toc.appendChild(visitorBox);

    const script = document.createElement("script");
    script.type = "text/javascript";
    script.id = "mapmyvisitors";
    script.src = "https://mapmyvisitors.com/map.js?d=VB4CQ-pHjslsyMmR0rw4s_DypvFk9m4uOmjvwzOeddI&cl=ffffff&w=a";

    visitorBox.appendChild(script);
  }

});
</script>