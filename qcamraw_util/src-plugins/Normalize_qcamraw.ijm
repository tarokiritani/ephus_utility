run("Import Qcamraw");
divided_image = getTitle();
Dialog.create("baseline frames");
Dialog.addNumber("from: ", 1);
Dialog.addNumber("to: ", 8);
Dialog.show();
startFrame = Dialog.getNumber();
endFrame = Dialog.getNumber();

run("Z Project...", "start=startFrame stop=endFrame projection=[Average Intensity]");
base_image = getTitle();


imageCalculator("Divide create 32-bit stack", divided_image, base_image);
normalized_image = getTitle();
selectWindow(divided_image);
close();
selectWindow(base_image);
close();
selectWindow(normalized_image);
run("16_colors");
