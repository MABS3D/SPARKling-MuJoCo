"""Cases distinguishing 3.15 coupled FLEX assembly from the old XYZ shortcut."""
import xml.etree.ElementTree as ET


def additional_fixtures(fixture):
    for variant in ("rotated_vertices", "axis_order", "hinge_offset", "weld_offset", "free_bending"):
        tree = ET.fromstring(fixture(curved=True, free=variant == "free_bending"))
        flex = tree.find("deformable/flex")
        names = flex.get("body").split()
        offsets = []
        for i, body in enumerate(tree.findall("worldbody/body")):
            if variant == "rotated_vertices":
                body.set("quat", (".9659258262890683 .2588190451025207 0 0" if i % 2 else
                                  ".9238795325112867 0 .3826834323650898 0"))
            if variant == "axis_order":
                for joint, axis in zip(body.findall("joint"), ("0 -1 0", "0 0 1", "-1 0 0")):
                    joint.set("axis", axis)
            if variant == "hinge_offset":
                for joint in list(body.findall("joint")):
                    body.remove(joint)
                ET.SubElement(body, "joint", dict(type="hinge", axis="0 1 0", damping=".013"))
            if variant == "weld_offset":
                child = ET.SubElement(body, "body", dict(name=names[i] + "_weld", pos=".04 -.03 .02"))
                names[i] = child.get("name")
            offsets.append(".03 .02 -.01" if variant in ("hinge_offset", "weld_offset", "free_bending") else "0 0 0")
        flex.set("body", " ".join(names))
        flex.set("vertex", " ".join(offsets))
        yield "coupled_" + variant, ET.tostring(tree, encoding="unicode")

    # Two tetrahedra with different reference geometry expose the 24-slot
    # element stride; a single element cannot distinguish it from 21 slots.
    tree = ET.fromstring(fixture(dim=3, mode="none"))
    world = tree.find("worldbody")
    body = ET.SubElement(world, "body", dict(name="v0_4", pos="1 1 1.2"))
    for axis in ("1 0 0", "0 1 0", "0 0 1"):
        ET.SubElement(body, "joint", dict(type="slide", axis=axis, damping=".013"))
    ET.SubElement(body, "inertial", dict(mass="1", pos=".03 -.02 .01", diaginertia=".1 .11 .12"))
    flex = tree.find("deformable/flex")
    flex.set("body", flex.get("body") + " v0_4")
    flex.set("vertex", flex.get("vertex") + " 0 0 0")
    flex.set("element", "0 1 2 3 1 2 3 4")
    yield "multi_tetra_stride", ET.tostring(tree, encoding="unicode")


def additional_constrained_fixtures(fixture):
    for name, xml in additional_fixtures(fixture):
        tree = ET.fromstring(xml)
        option = tree.find("option")
        option.set("solver", "Newton")
        option.set("iterations", "200")
        option.set("tolerance", "1e-12")
        option.set("jacobian", "sparse")
        option.find("flag").attrib.clear()
        option.find("flag").set("warmstart", "disable")
        option.find("flag").set("island", "disable")
        ET.SubElement(tree.find("worldbody"), "geom", dict(type="plane", size="3 3 .1", pos="0 0 -.01", condim="3"))
        flex = tree.find("deformable/flex")
        flex.set("radius", ".015")
        contact = flex.find("contact")
        contact.set("contype", "1")
        contact.set("conaffinity", "1")
        contact.set("condim", "3")
        yield name, ET.tostring(tree, encoding="unicode")
