with MJ.Types; use MJ.Types;
package body MJ.Plugin_Model_Copy with SPARK_Mode is
   procedure Build (Source : MJ.Models.Model; Base : in out MJ.Models.Model) is
      S : MJ.Models.Sizes := Source.S;
   begin
      S.Nplugin := 0; S.Npluginattr := 0; S.Npluginstate := 0;
      MJ.Models.Allocate (S, Base);
      Base.Opt := Source.Opt;
      Base.Vis := Source.Vis;
      Base.Stat := Source.Stat;
      Base.Flg_Gravcomp := Source.Flg_Gravcomp;
      Base.Flg_Surfacevel := Source.Flg_Surfacevel;
      Base.Flg_Adhesion := Source.Flg_Adhesion;
      Base.Caps := Source.Caps;
      if Base.Bodies.Body_Parentid /= null then
         for I in Base.Bodies.Body_Parentid'Range loop
            Base.Bodies.Body_Parentid (I) := Source.Bodies.Body_Parentid (I);
         end loop;
      end if;
      if Base.Bodies.Body_Rootid /= null then
         for I in Base.Bodies.Body_Rootid'Range loop
            Base.Bodies.Body_Rootid (I) := Source.Bodies.Body_Rootid (I);
         end loop;
      end if;
      if Base.Bodies.Body_Weldid /= null then
         for I in Base.Bodies.Body_Weldid'Range loop
            Base.Bodies.Body_Weldid (I) := Source.Bodies.Body_Weldid (I);
         end loop;
      end if;
      if Base.Bodies.Body_Mocapid /= null then
         for I in Base.Bodies.Body_Mocapid'Range loop
            Base.Bodies.Body_Mocapid (I) := Source.Bodies.Body_Mocapid (I);
         end loop;
      end if;
      if Base.Bodies.Body_Jntnum /= null then
         for I in Base.Bodies.Body_Jntnum'Range loop
            Base.Bodies.Body_Jntnum (I) := Source.Bodies.Body_Jntnum (I);
         end loop;
      end if;
      if Base.Bodies.Body_Jntadr /= null then
         for I in Base.Bodies.Body_Jntadr'Range loop
            Base.Bodies.Body_Jntadr (I) := Source.Bodies.Body_Jntadr (I);
         end loop;
      end if;
      if Base.Bodies.Body_Dofnum /= null then
         for I in Base.Bodies.Body_Dofnum'Range loop
            Base.Bodies.Body_Dofnum (I) := Source.Bodies.Body_Dofnum (I);
         end loop;
      end if;
      if Base.Bodies.Body_Dofadr /= null then
         for I in Base.Bodies.Body_Dofadr'Range loop
            Base.Bodies.Body_Dofadr (I) := Source.Bodies.Body_Dofadr (I);
         end loop;
      end if;
      if Base.Bodies.Body_Treeid /= null then
         for I in Base.Bodies.Body_Treeid'Range loop
            Base.Bodies.Body_Treeid (I) := Source.Bodies.Body_Treeid (I);
         end loop;
      end if;
      if Base.Bodies.Body_Geomnum /= null then
         for I in Base.Bodies.Body_Geomnum'Range loop
            Base.Bodies.Body_Geomnum (I) := Source.Bodies.Body_Geomnum (I);
         end loop;
      end if;
      if Base.Bodies.Body_Geomadr /= null then
         for I in Base.Bodies.Body_Geomadr'Range loop
            Base.Bodies.Body_Geomadr (I) := Source.Bodies.Body_Geomadr (I);
         end loop;
      end if;
      if Base.Bodies.Body_Simple /= null then
         for I in Base.Bodies.Body_Simple'Range loop
            Base.Bodies.Body_Simple (I) := Source.Bodies.Body_Simple (I);
         end loop;
      end if;
      if Base.Bodies.Body_Sameframe /= null then
         for I in Base.Bodies.Body_Sameframe'Range loop
            Base.Bodies.Body_Sameframe (I) := Source.Bodies.Body_Sameframe (I);
         end loop;
      end if;
      if Base.Bodies.Body_Pos /= null then
         for I in Base.Bodies.Body_Pos'Range loop
            Base.Bodies.Body_Pos (I) := Source.Bodies.Body_Pos (I);
         end loop;
      end if;
      if Base.Bodies.Body_Quat /= null then
         for I in Base.Bodies.Body_Quat'Range loop
            Base.Bodies.Body_Quat (I) := Source.Bodies.Body_Quat (I);
         end loop;
      end if;
      if Base.Bodies.Body_Ipos /= null then
         for I in Base.Bodies.Body_Ipos'Range loop
            Base.Bodies.Body_Ipos (I) := Source.Bodies.Body_Ipos (I);
         end loop;
      end if;
      if Base.Bodies.Body_Iquat /= null then
         for I in Base.Bodies.Body_Iquat'Range loop
            Base.Bodies.Body_Iquat (I) := Source.Bodies.Body_Iquat (I);
         end loop;
      end if;
      if Base.Bodies.Body_Mass /= null then
         for I in Base.Bodies.Body_Mass'Range loop
            Base.Bodies.Body_Mass (I) := Source.Bodies.Body_Mass (I);
         end loop;
      end if;
      if Base.Bodies.Body_Subtreemass /= null then
         for I in Base.Bodies.Body_Subtreemass'Range loop
            Base.Bodies.Body_Subtreemass (I) := Source.Bodies.Body_Subtreemass (I);
         end loop;
      end if;
      if Base.Bodies.Body_Inertia /= null then
         for I in Base.Bodies.Body_Inertia'Range loop
            Base.Bodies.Body_Inertia (I) := Source.Bodies.Body_Inertia (I);
         end loop;
      end if;
      if Base.Bodies.Body_Invweight0 /= null then
         for I in Base.Bodies.Body_Invweight0'Range loop
            Base.Bodies.Body_Invweight0 (I) := Source.Bodies.Body_Invweight0 (I);
         end loop;
      end if;
      if Base.Bodies.Body_Gravcomp /= null then
         for I in Base.Bodies.Body_Gravcomp'Range loop
            Base.Bodies.Body_Gravcomp (I) := Source.Bodies.Body_Gravcomp (I);
         end loop;
      end if;
      if Base.Bodies.Body_Margin /= null then
         for I in Base.Bodies.Body_Margin'Range loop
            Base.Bodies.Body_Margin (I) := Source.Bodies.Body_Margin (I);
         end loop;
      end if;
      if Base.Bodies.Body_User /= null then
         for I in Base.Bodies.Body_User'Range loop
            Base.Bodies.Body_User (I) := Source.Bodies.Body_User (I);
         end loop;
      end if;
      if Base.Bodies.Body_Plugin /= null then
         for I in Base.Bodies.Body_Plugin'Range loop
            Base.Bodies.Body_Plugin (I) := Source.Bodies.Body_Plugin (I);
         end loop;
      end if;
      if Base.Bodies.Body_Contype /= null then
         for I in Base.Bodies.Body_Contype'Range loop
            Base.Bodies.Body_Contype (I) := Source.Bodies.Body_Contype (I);
         end loop;
      end if;
      if Base.Bodies.Body_Conaffinity /= null then
         for I in Base.Bodies.Body_Conaffinity'Range loop
            Base.Bodies.Body_Conaffinity (I) := Source.Bodies.Body_Conaffinity (I);
         end loop;
      end if;
      if Base.Bodies.Body_Bvhadr /= null then
         for I in Base.Bodies.Body_Bvhadr'Range loop
            Base.Bodies.Body_Bvhadr (I) := Source.Bodies.Body_Bvhadr (I);
         end loop;
      end if;
      if Base.Bodies.Body_Bvhnum /= null then
         for I in Base.Bodies.Body_Bvhnum'Range loop
            Base.Bodies.Body_Bvhnum (I) := Source.Bodies.Body_Bvhnum (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Type /= null then
         for I in Base.Joints.Jnt_Type'Range loop
            Base.Joints.Jnt_Type (I) := Source.Joints.Jnt_Type (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Qposadr /= null then
         for I in Base.Joints.Jnt_Qposadr'Range loop
            Base.Joints.Jnt_Qposadr (I) := Source.Joints.Jnt_Qposadr (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Dofadr /= null then
         for I in Base.Joints.Jnt_Dofadr'Range loop
            Base.Joints.Jnt_Dofadr (I) := Source.Joints.Jnt_Dofadr (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Bodyid /= null then
         for I in Base.Joints.Jnt_Bodyid'Range loop
            Base.Joints.Jnt_Bodyid (I) := Source.Joints.Jnt_Bodyid (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Actuatorid /= null then
         for I in Base.Joints.Jnt_Actuatorid'Range loop
            Base.Joints.Jnt_Actuatorid (I) := Source.Joints.Jnt_Actuatorid (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Group /= null then
         for I in Base.Joints.Jnt_Group'Range loop
            Base.Joints.Jnt_Group (I) := Source.Joints.Jnt_Group (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Limited /= null then
         for I in Base.Joints.Jnt_Limited'Range loop
            Base.Joints.Jnt_Limited (I) := Source.Joints.Jnt_Limited (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Actfrclimited /= null then
         for I in Base.Joints.Jnt_Actfrclimited'Range loop
            Base.Joints.Jnt_Actfrclimited (I) := Source.Joints.Jnt_Actfrclimited (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Actgravcomp /= null then
         for I in Base.Joints.Jnt_Actgravcomp'Range loop
            Base.Joints.Jnt_Actgravcomp (I) := Source.Joints.Jnt_Actgravcomp (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Solref /= null then
         for I in Base.Joints.Jnt_Solref'Range loop
            Base.Joints.Jnt_Solref (I) := Source.Joints.Jnt_Solref (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Solimp /= null then
         for I in Base.Joints.Jnt_Solimp'Range loop
            Base.Joints.Jnt_Solimp (I) := Source.Joints.Jnt_Solimp (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Pos /= null then
         for I in Base.Joints.Jnt_Pos'Range loop
            Base.Joints.Jnt_Pos (I) := Source.Joints.Jnt_Pos (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Axis /= null then
         for I in Base.Joints.Jnt_Axis'Range loop
            Base.Joints.Jnt_Axis (I) := Source.Joints.Jnt_Axis (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Stiffness /= null then
         for I in Base.Joints.Jnt_Stiffness'Range loop
            Base.Joints.Jnt_Stiffness (I) := Source.Joints.Jnt_Stiffness (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Stiffnesspoly /= null then
         for I in Base.Joints.Jnt_Stiffnesspoly'Range loop
            Base.Joints.Jnt_Stiffnesspoly (I) := Source.Joints.Jnt_Stiffnesspoly (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Range /= null then
         for I in Base.Joints.Jnt_Range'Range loop
            Base.Joints.Jnt_Range (I) := Source.Joints.Jnt_Range (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Actfrcrange /= null then
         for I in Base.Joints.Jnt_Actfrcrange'Range loop
            Base.Joints.Jnt_Actfrcrange (I) := Source.Joints.Jnt_Actfrcrange (I);
         end loop;
      end if;
      if Base.Joints.Jnt_Margin /= null then
         for I in Base.Joints.Jnt_Margin'Range loop
            Base.Joints.Jnt_Margin (I) := Source.Joints.Jnt_Margin (I);
         end loop;
      end if;
      if Base.Joints.Jnt_User /= null then
         for I in Base.Joints.Jnt_User'Range loop
            Base.Joints.Jnt_User (I) := Source.Joints.Jnt_User (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Bodyid /= null then
         for I in Base.Dofs.Dof_Bodyid'Range loop
            Base.Dofs.Dof_Bodyid (I) := Source.Dofs.Dof_Bodyid (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Jntid /= null then
         for I in Base.Dofs.Dof_Jntid'Range loop
            Base.Dofs.Dof_Jntid (I) := Source.Dofs.Dof_Jntid (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Parentid /= null then
         for I in Base.Dofs.Dof_Parentid'Range loop
            Base.Dofs.Dof_Parentid (I) := Source.Dofs.Dof_Parentid (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Treeid /= null then
         for I in Base.Dofs.Dof_Treeid'Range loop
            Base.Dofs.Dof_Treeid (I) := Source.Dofs.Dof_Treeid (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Madr /= null then
         for I in Base.Dofs.Dof_Madr'Range loop
            Base.Dofs.Dof_Madr (I) := Source.Dofs.Dof_Madr (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Simplenum /= null then
         for I in Base.Dofs.Dof_Simplenum'Range loop
            Base.Dofs.Dof_Simplenum (I) := Source.Dofs.Dof_Simplenum (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Solref /= null then
         for I in Base.Dofs.Dof_Solref'Range loop
            Base.Dofs.Dof_Solref (I) := Source.Dofs.Dof_Solref (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Solimp /= null then
         for I in Base.Dofs.Dof_Solimp'Range loop
            Base.Dofs.Dof_Solimp (I) := Source.Dofs.Dof_Solimp (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Frictionloss /= null then
         for I in Base.Dofs.Dof_Frictionloss'Range loop
            Base.Dofs.Dof_Frictionloss (I) := Source.Dofs.Dof_Frictionloss (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Armature /= null then
         for I in Base.Dofs.Dof_Armature'Range loop
            Base.Dofs.Dof_Armature (I) := Source.Dofs.Dof_Armature (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Damping /= null then
         for I in Base.Dofs.Dof_Damping'Range loop
            Base.Dofs.Dof_Damping (I) := Source.Dofs.Dof_Damping (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Dampingpoly /= null then
         for I in Base.Dofs.Dof_Dampingpoly'Range loop
            Base.Dofs.Dof_Dampingpoly (I) := Source.Dofs.Dof_Dampingpoly (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Invweight0 /= null then
         for I in Base.Dofs.Dof_Invweight0'Range loop
            Base.Dofs.Dof_Invweight0 (I) := Source.Dofs.Dof_Invweight0 (I);
         end loop;
      end if;
      if Base.Dofs.Dof_M0 /= null then
         for I in Base.Dofs.Dof_M0'Range loop
            Base.Dofs.Dof_M0 (I) := Source.Dofs.Dof_M0 (I);
         end loop;
      end if;
      if Base.Dofs.Dof_Length /= null then
         for I in Base.Dofs.Dof_Length'Range loop
            Base.Dofs.Dof_Length (I) := Source.Dofs.Dof_Length (I);
         end loop;
      end if;
      if Base.Trees.Tree_Bodyadr /= null then
         for I in Base.Trees.Tree_Bodyadr'Range loop
            Base.Trees.Tree_Bodyadr (I) := Source.Trees.Tree_Bodyadr (I);
         end loop;
      end if;
      if Base.Trees.Tree_Bodynum /= null then
         for I in Base.Trees.Tree_Bodynum'Range loop
            Base.Trees.Tree_Bodynum (I) := Source.Trees.Tree_Bodynum (I);
         end loop;
      end if;
      if Base.Trees.Tree_Dofadr /= null then
         for I in Base.Trees.Tree_Dofadr'Range loop
            Base.Trees.Tree_Dofadr (I) := Source.Trees.Tree_Dofadr (I);
         end loop;
      end if;
      if Base.Trees.Tree_Dofnum /= null then
         for I in Base.Trees.Tree_Dofnum'Range loop
            Base.Trees.Tree_Dofnum (I) := Source.Trees.Tree_Dofnum (I);
         end loop;
      end if;
      if Base.Trees.Tree_Sleep_Policy /= null then
         for I in Base.Trees.Tree_Sleep_Policy'Range loop
            Base.Trees.Tree_Sleep_Policy (I) := Source.Trees.Tree_Sleep_Policy (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Type /= null then
         for I in Base.Geoms.Geom_Type'Range loop
            Base.Geoms.Geom_Type (I) := Source.Geoms.Geom_Type (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Contype /= null then
         for I in Base.Geoms.Geom_Contype'Range loop
            Base.Geoms.Geom_Contype (I) := Source.Geoms.Geom_Contype (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Conaffinity /= null then
         for I in Base.Geoms.Geom_Conaffinity'Range loop
            Base.Geoms.Geom_Conaffinity (I) := Source.Geoms.Geom_Conaffinity (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Condim /= null then
         for I in Base.Geoms.Geom_Condim'Range loop
            Base.Geoms.Geom_Condim (I) := Source.Geoms.Geom_Condim (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Bodyid /= null then
         for I in Base.Geoms.Geom_Bodyid'Range loop
            Base.Geoms.Geom_Bodyid (I) := Source.Geoms.Geom_Bodyid (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Dataid /= null then
         for I in Base.Geoms.Geom_Dataid'Range loop
            Base.Geoms.Geom_Dataid (I) := Source.Geoms.Geom_Dataid (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Matid /= null then
         for I in Base.Geoms.Geom_Matid'Range loop
            Base.Geoms.Geom_Matid (I) := Source.Geoms.Geom_Matid (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Group /= null then
         for I in Base.Geoms.Geom_Group'Range loop
            Base.Geoms.Geom_Group (I) := Source.Geoms.Geom_Group (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Priority /= null then
         for I in Base.Geoms.Geom_Priority'Range loop
            Base.Geoms.Geom_Priority (I) := Source.Geoms.Geom_Priority (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Plugin /= null then
         for I in Base.Geoms.Geom_Plugin'Range loop
            Base.Geoms.Geom_Plugin (I) := Source.Geoms.Geom_Plugin (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Sameframe /= null then
         for I in Base.Geoms.Geom_Sameframe'Range loop
            Base.Geoms.Geom_Sameframe (I) := Source.Geoms.Geom_Sameframe (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Solmix /= null then
         for I in Base.Geoms.Geom_Solmix'Range loop
            Base.Geoms.Geom_Solmix (I) := Source.Geoms.Geom_Solmix (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Solref /= null then
         for I in Base.Geoms.Geom_Solref'Range loop
            Base.Geoms.Geom_Solref (I) := Source.Geoms.Geom_Solref (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Solimp /= null then
         for I in Base.Geoms.Geom_Solimp'Range loop
            Base.Geoms.Geom_Solimp (I) := Source.Geoms.Geom_Solimp (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Size /= null then
         for I in Base.Geoms.Geom_Size'Range loop
            Base.Geoms.Geom_Size (I) := Source.Geoms.Geom_Size (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Aabb /= null then
         for I in Base.Geoms.Geom_Aabb'Range loop
            Base.Geoms.Geom_Aabb (I) := Source.Geoms.Geom_Aabb (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Rbound /= null then
         for I in Base.Geoms.Geom_Rbound'Range loop
            Base.Geoms.Geom_Rbound (I) := Source.Geoms.Geom_Rbound (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Pos /= null then
         for I in Base.Geoms.Geom_Pos'Range loop
            Base.Geoms.Geom_Pos (I) := Source.Geoms.Geom_Pos (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Quat /= null then
         for I in Base.Geoms.Geom_Quat'Range loop
            Base.Geoms.Geom_Quat (I) := Source.Geoms.Geom_Quat (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Friction /= null then
         for I in Base.Geoms.Geom_Friction'Range loop
            Base.Geoms.Geom_Friction (I) := Source.Geoms.Geom_Friction (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Margin /= null then
         for I in Base.Geoms.Geom_Margin'Range loop
            Base.Geoms.Geom_Margin (I) := Source.Geoms.Geom_Margin (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Gap /= null then
         for I in Base.Geoms.Geom_Gap'Range loop
            Base.Geoms.Geom_Gap (I) := Source.Geoms.Geom_Gap (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Surfacevel /= null then
         for I in Base.Geoms.Geom_Surfacevel'Range loop
            Base.Geoms.Geom_Surfacevel (I) := Source.Geoms.Geom_Surfacevel (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Adhesion /= null then
         for I in Base.Geoms.Geom_Adhesion'Range loop
            Base.Geoms.Geom_Adhesion (I) := Source.Geoms.Geom_Adhesion (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Fluid /= null then
         for I in Base.Geoms.Geom_Fluid'Range loop
            Base.Geoms.Geom_Fluid (I) := Source.Geoms.Geom_Fluid (I);
         end loop;
      end if;
      if Base.Geoms.Geom_User /= null then
         for I in Base.Geoms.Geom_User'Range loop
            Base.Geoms.Geom_User (I) := Source.Geoms.Geom_User (I);
         end loop;
      end if;
      if Base.Geoms.Geom_Rgba /= null then
         for I in Base.Geoms.Geom_Rgba'Range loop
            Base.Geoms.Geom_Rgba (I) := Source.Geoms.Geom_Rgba (I);
         end loop;
      end if;
      if Base.Sites.Site_Type /= null then
         for I in Base.Sites.Site_Type'Range loop
            Base.Sites.Site_Type (I) := Source.Sites.Site_Type (I);
         end loop;
      end if;
      if Base.Sites.Site_Bodyid /= null then
         for I in Base.Sites.Site_Bodyid'Range loop
            Base.Sites.Site_Bodyid (I) := Source.Sites.Site_Bodyid (I);
         end loop;
      end if;
      if Base.Sites.Site_Dataid /= null then
         for I in Base.Sites.Site_Dataid'Range loop
            Base.Sites.Site_Dataid (I) := Source.Sites.Site_Dataid (I);
         end loop;
      end if;
      if Base.Sites.Site_Matid /= null then
         for I in Base.Sites.Site_Matid'Range loop
            Base.Sites.Site_Matid (I) := Source.Sites.Site_Matid (I);
         end loop;
      end if;
      if Base.Sites.Site_Group /= null then
         for I in Base.Sites.Site_Group'Range loop
            Base.Sites.Site_Group (I) := Source.Sites.Site_Group (I);
         end loop;
      end if;
      if Base.Sites.Site_Sameframe /= null then
         for I in Base.Sites.Site_Sameframe'Range loop
            Base.Sites.Site_Sameframe (I) := Source.Sites.Site_Sameframe (I);
         end loop;
      end if;
      if Base.Sites.Site_Size /= null then
         for I in Base.Sites.Site_Size'Range loop
            Base.Sites.Site_Size (I) := Source.Sites.Site_Size (I);
         end loop;
      end if;
      if Base.Sites.Site_Pos /= null then
         for I in Base.Sites.Site_Pos'Range loop
            Base.Sites.Site_Pos (I) := Source.Sites.Site_Pos (I);
         end loop;
      end if;
      if Base.Sites.Site_Quat /= null then
         for I in Base.Sites.Site_Quat'Range loop
            Base.Sites.Site_Quat (I) := Source.Sites.Site_Quat (I);
         end loop;
      end if;
      if Base.Sites.Site_User /= null then
         for I in Base.Sites.Site_User'Range loop
            Base.Sites.Site_User (I) := Source.Sites.Site_User (I);
         end loop;
      end if;
      if Base.Sites.Site_Rgba /= null then
         for I in Base.Sites.Site_Rgba'Range loop
            Base.Sites.Site_Rgba (I) := Source.Sites.Site_Rgba (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Mode /= null then
         for I in Base.Cameras.Cam_Mode'Range loop
            Base.Cameras.Cam_Mode (I) := Source.Cameras.Cam_Mode (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Bodyid /= null then
         for I in Base.Cameras.Cam_Bodyid'Range loop
            Base.Cameras.Cam_Bodyid (I) := Source.Cameras.Cam_Bodyid (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Targetbodyid /= null then
         for I in Base.Cameras.Cam_Targetbodyid'Range loop
            Base.Cameras.Cam_Targetbodyid (I) := Source.Cameras.Cam_Targetbodyid (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Pos /= null then
         for I in Base.Cameras.Cam_Pos'Range loop
            Base.Cameras.Cam_Pos (I) := Source.Cameras.Cam_Pos (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Quat /= null then
         for I in Base.Cameras.Cam_Quat'Range loop
            Base.Cameras.Cam_Quat (I) := Source.Cameras.Cam_Quat (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Poscom0 /= null then
         for I in Base.Cameras.Cam_Poscom0'Range loop
            Base.Cameras.Cam_Poscom0 (I) := Source.Cameras.Cam_Poscom0 (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Pos0 /= null then
         for I in Base.Cameras.Cam_Pos0'Range loop
            Base.Cameras.Cam_Pos0 (I) := Source.Cameras.Cam_Pos0 (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Mat0 /= null then
         for I in Base.Cameras.Cam_Mat0'Range loop
            Base.Cameras.Cam_Mat0 (I) := Source.Cameras.Cam_Mat0 (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Projection /= null then
         for I in Base.Cameras.Cam_Projection'Range loop
            Base.Cameras.Cam_Projection (I) := Source.Cameras.Cam_Projection (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Fovy /= null then
         for I in Base.Cameras.Cam_Fovy'Range loop
            Base.Cameras.Cam_Fovy (I) := Source.Cameras.Cam_Fovy (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Ipd /= null then
         for I in Base.Cameras.Cam_Ipd'Range loop
            Base.Cameras.Cam_Ipd (I) := Source.Cameras.Cam_Ipd (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Resolution /= null then
         for I in Base.Cameras.Cam_Resolution'Range loop
            Base.Cameras.Cam_Resolution (I) := Source.Cameras.Cam_Resolution (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Output /= null then
         for I in Base.Cameras.Cam_Output'Range loop
            Base.Cameras.Cam_Output (I) := Source.Cameras.Cam_Output (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Sensorsize /= null then
         for I in Base.Cameras.Cam_Sensorsize'Range loop
            Base.Cameras.Cam_Sensorsize (I) := Source.Cameras.Cam_Sensorsize (I);
         end loop;
      end if;
      if Base.Cameras.Cam_Intrinsic /= null then
         for I in Base.Cameras.Cam_Intrinsic'Range loop
            Base.Cameras.Cam_Intrinsic (I) := Source.Cameras.Cam_Intrinsic (I);
         end loop;
      end if;
      if Base.Cameras.Cam_User /= null then
         for I in Base.Cameras.Cam_User'Range loop
            Base.Cameras.Cam_User (I) := Source.Cameras.Cam_User (I);
         end loop;
      end if;
      if Base.Lights.Light_Mode /= null then
         for I in Base.Lights.Light_Mode'Range loop
            Base.Lights.Light_Mode (I) := Source.Lights.Light_Mode (I);
         end loop;
      end if;
      if Base.Lights.Light_Bodyid /= null then
         for I in Base.Lights.Light_Bodyid'Range loop
            Base.Lights.Light_Bodyid (I) := Source.Lights.Light_Bodyid (I);
         end loop;
      end if;
      if Base.Lights.Light_Targetbodyid /= null then
         for I in Base.Lights.Light_Targetbodyid'Range loop
            Base.Lights.Light_Targetbodyid (I) := Source.Lights.Light_Targetbodyid (I);
         end loop;
      end if;
      if Base.Lights.Light_Type /= null then
         for I in Base.Lights.Light_Type'Range loop
            Base.Lights.Light_Type (I) := Source.Lights.Light_Type (I);
         end loop;
      end if;
      if Base.Lights.Light_Texid /= null then
         for I in Base.Lights.Light_Texid'Range loop
            Base.Lights.Light_Texid (I) := Source.Lights.Light_Texid (I);
         end loop;
      end if;
      if Base.Lights.Light_Castshadow /= null then
         for I in Base.Lights.Light_Castshadow'Range loop
            Base.Lights.Light_Castshadow (I) := Source.Lights.Light_Castshadow (I);
         end loop;
      end if;
      if Base.Lights.Light_Bulbradius /= null then
         for I in Base.Lights.Light_Bulbradius'Range loop
            Base.Lights.Light_Bulbradius (I) := Source.Lights.Light_Bulbradius (I);
         end loop;
      end if;
      if Base.Lights.Light_Intensity /= null then
         for I in Base.Lights.Light_Intensity'Range loop
            Base.Lights.Light_Intensity (I) := Source.Lights.Light_Intensity (I);
         end loop;
      end if;
      if Base.Lights.Light_Range /= null then
         for I in Base.Lights.Light_Range'Range loop
            Base.Lights.Light_Range (I) := Source.Lights.Light_Range (I);
         end loop;
      end if;
      if Base.Lights.Light_Active /= null then
         for I in Base.Lights.Light_Active'Range loop
            Base.Lights.Light_Active (I) := Source.Lights.Light_Active (I);
         end loop;
      end if;
      if Base.Lights.Light_Pos /= null then
         for I in Base.Lights.Light_Pos'Range loop
            Base.Lights.Light_Pos (I) := Source.Lights.Light_Pos (I);
         end loop;
      end if;
      if Base.Lights.Light_Dir /= null then
         for I in Base.Lights.Light_Dir'Range loop
            Base.Lights.Light_Dir (I) := Source.Lights.Light_Dir (I);
         end loop;
      end if;
      if Base.Lights.Light_Poscom0 /= null then
         for I in Base.Lights.Light_Poscom0'Range loop
            Base.Lights.Light_Poscom0 (I) := Source.Lights.Light_Poscom0 (I);
         end loop;
      end if;
      if Base.Lights.Light_Pos0 /= null then
         for I in Base.Lights.Light_Pos0'Range loop
            Base.Lights.Light_Pos0 (I) := Source.Lights.Light_Pos0 (I);
         end loop;
      end if;
      if Base.Lights.Light_Dir0 /= null then
         for I in Base.Lights.Light_Dir0'Range loop
            Base.Lights.Light_Dir0 (I) := Source.Lights.Light_Dir0 (I);
         end loop;
      end if;
      if Base.Lights.Light_Attenuation /= null then
         for I in Base.Lights.Light_Attenuation'Range loop
            Base.Lights.Light_Attenuation (I) := Source.Lights.Light_Attenuation (I);
         end loop;
      end if;
      if Base.Lights.Light_Cutoff /= null then
         for I in Base.Lights.Light_Cutoff'Range loop
            Base.Lights.Light_Cutoff (I) := Source.Lights.Light_Cutoff (I);
         end loop;
      end if;
      if Base.Lights.Light_Softness /= null then
         for I in Base.Lights.Light_Softness'Range loop
            Base.Lights.Light_Softness (I) := Source.Lights.Light_Softness (I);
         end loop;
      end if;
      if Base.Lights.Light_Exponent /= null then
         for I in Base.Lights.Light_Exponent'Range loop
            Base.Lights.Light_Exponent (I) := Source.Lights.Light_Exponent (I);
         end loop;
      end if;
      if Base.Lights.Light_Ambient /= null then
         for I in Base.Lights.Light_Ambient'Range loop
            Base.Lights.Light_Ambient (I) := Source.Lights.Light_Ambient (I);
         end loop;
      end if;
      if Base.Lights.Light_Diffuse /= null then
         for I in Base.Lights.Light_Diffuse'Range loop
            Base.Lights.Light_Diffuse (I) := Source.Lights.Light_Diffuse (I);
         end loop;
      end if;
      if Base.Lights.Light_Specular /= null then
         for I in Base.Lights.Light_Specular'Range loop
            Base.Lights.Light_Specular (I) := Source.Lights.Light_Specular (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Contype /= null then
         for I in Base.Flexes.Flex_Contype'Range loop
            Base.Flexes.Flex_Contype (I) := Source.Flexes.Flex_Contype (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Conaffinity /= null then
         for I in Base.Flexes.Flex_Conaffinity'Range loop
            Base.Flexes.Flex_Conaffinity (I) := Source.Flexes.Flex_Conaffinity (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Condim /= null then
         for I in Base.Flexes.Flex_Condim'Range loop
            Base.Flexes.Flex_Condim (I) := Source.Flexes.Flex_Condim (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Priority /= null then
         for I in Base.Flexes.Flex_Priority'Range loop
            Base.Flexes.Flex_Priority (I) := Source.Flexes.Flex_Priority (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Solmix /= null then
         for I in Base.Flexes.Flex_Solmix'Range loop
            Base.Flexes.Flex_Solmix (I) := Source.Flexes.Flex_Solmix (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Solref /= null then
         for I in Base.Flexes.Flex_Solref'Range loop
            Base.Flexes.Flex_Solref (I) := Source.Flexes.Flex_Solref (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Solimp /= null then
         for I in Base.Flexes.Flex_Solimp'Range loop
            Base.Flexes.Flex_Solimp (I) := Source.Flexes.Flex_Solimp (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Friction /= null then
         for I in Base.Flexes.Flex_Friction'Range loop
            Base.Flexes.Flex_Friction (I) := Source.Flexes.Flex_Friction (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Margin /= null then
         for I in Base.Flexes.Flex_Margin'Range loop
            Base.Flexes.Flex_Margin (I) := Source.Flexes.Flex_Margin (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Gap /= null then
         for I in Base.Flexes.Flex_Gap'Range loop
            Base.Flexes.Flex_Gap (I) := Source.Flexes.Flex_Gap (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Internal /= null then
         for I in Base.Flexes.Flex_Internal'Range loop
            Base.Flexes.Flex_Internal (I) := Source.Flexes.Flex_Internal (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Selfcollide /= null then
         for I in Base.Flexes.Flex_Selfcollide'Range loop
            Base.Flexes.Flex_Selfcollide (I) := Source.Flexes.Flex_Selfcollide (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Activelayers /= null then
         for I in Base.Flexes.Flex_Activelayers'Range loop
            Base.Flexes.Flex_Activelayers (I) := Source.Flexes.Flex_Activelayers (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Passive /= null then
         for I in Base.Flexes.Flex_Passive'Range loop
            Base.Flexes.Flex_Passive (I) := Source.Flexes.Flex_Passive (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Dim /= null then
         for I in Base.Flexes.Flex_Dim'Range loop
            Base.Flexes.Flex_Dim (I) := Source.Flexes.Flex_Dim (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Matid /= null then
         for I in Base.Flexes.Flex_Matid'Range loop
            Base.Flexes.Flex_Matid (I) := Source.Flexes.Flex_Matid (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Group /= null then
         for I in Base.Flexes.Flex_Group'Range loop
            Base.Flexes.Flex_Group (I) := Source.Flexes.Flex_Group (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Interp /= null then
         for I in Base.Flexes.Flex_Interp'Range loop
            Base.Flexes.Flex_Interp (I) := Source.Flexes.Flex_Interp (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Cellnum /= null then
         for I in Base.Flexes.Flex_Cellnum'Range loop
            Base.Flexes.Flex_Cellnum (I) := Source.Flexes.Flex_Cellnum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Nodeadr /= null then
         for I in Base.Flexes.Flex_Nodeadr'Range loop
            Base.Flexes.Flex_Nodeadr (I) := Source.Flexes.Flex_Nodeadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Nodenum /= null then
         for I in Base.Flexes.Flex_Nodenum'Range loop
            Base.Flexes.Flex_Nodenum (I) := Source.Flexes.Flex_Nodenum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vertadr /= null then
         for I in Base.Flexes.Flex_Vertadr'Range loop
            Base.Flexes.Flex_Vertadr (I) := Source.Flexes.Flex_Vertadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vertnum /= null then
         for I in Base.Flexes.Flex_Vertnum'Range loop
            Base.Flexes.Flex_Vertnum (I) := Source.Flexes.Flex_Vertnum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Edgeadr /= null then
         for I in Base.Flexes.Flex_Edgeadr'Range loop
            Base.Flexes.Flex_Edgeadr (I) := Source.Flexes.Flex_Edgeadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Edgenum /= null then
         for I in Base.Flexes.Flex_Edgenum'Range loop
            Base.Flexes.Flex_Edgenum (I) := Source.Flexes.Flex_Edgenum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elemadr /= null then
         for I in Base.Flexes.Flex_Elemadr'Range loop
            Base.Flexes.Flex_Elemadr (I) := Source.Flexes.Flex_Elemadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elemnum /= null then
         for I in Base.Flexes.Flex_Elemnum'Range loop
            Base.Flexes.Flex_Elemnum (I) := Source.Flexes.Flex_Elemnum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elemdataadr /= null then
         for I in Base.Flexes.Flex_Elemdataadr'Range loop
            Base.Flexes.Flex_Elemdataadr (I) := Source.Flexes.Flex_Elemdataadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Stiffnessadr /= null then
         for I in Base.Flexes.Flex_Stiffnessadr'Range loop
            Base.Flexes.Flex_Stiffnessadr (I) := Source.Flexes.Flex_Stiffnessadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elemedgeadr /= null then
         for I in Base.Flexes.Flex_Elemedgeadr'Range loop
            Base.Flexes.Flex_Elemedgeadr (I) := Source.Flexes.Flex_Elemedgeadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Bendingadr /= null then
         for I in Base.Flexes.Flex_Bendingadr'Range loop
            Base.Flexes.Flex_Bendingadr (I) := Source.Flexes.Flex_Bendingadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Shellnum /= null then
         for I in Base.Flexes.Flex_Shellnum'Range loop
            Base.Flexes.Flex_Shellnum (I) := Source.Flexes.Flex_Shellnum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Shelldataadr /= null then
         for I in Base.Flexes.Flex_Shelldataadr'Range loop
            Base.Flexes.Flex_Shelldataadr (I) := Source.Flexes.Flex_Shelldataadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Evpairadr /= null then
         for I in Base.Flexes.Flex_Evpairadr'Range loop
            Base.Flexes.Flex_Evpairadr (I) := Source.Flexes.Flex_Evpairadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Evpairnum /= null then
         for I in Base.Flexes.Flex_Evpairnum'Range loop
            Base.Flexes.Flex_Evpairnum (I) := Source.Flexes.Flex_Evpairnum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Texcoordadr /= null then
         for I in Base.Flexes.Flex_Texcoordadr'Range loop
            Base.Flexes.Flex_Texcoordadr (I) := Source.Flexes.Flex_Texcoordadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Nodebodyid /= null then
         for I in Base.Flexes.Flex_Nodebodyid'Range loop
            Base.Flexes.Flex_Nodebodyid (I) := Source.Flexes.Flex_Nodebodyid (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vertbodyid /= null then
         for I in Base.Flexes.Flex_Vertbodyid'Range loop
            Base.Flexes.Flex_Vertbodyid (I) := Source.Flexes.Flex_Vertbodyid (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vertedgeadr /= null then
         for I in Base.Flexes.Flex_Vertedgeadr'Range loop
            Base.Flexes.Flex_Vertedgeadr (I) := Source.Flexes.Flex_Vertedgeadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vertedgenum /= null then
         for I in Base.Flexes.Flex_Vertedgenum'Range loop
            Base.Flexes.Flex_Vertedgenum (I) := Source.Flexes.Flex_Vertedgenum (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vertedge /= null then
         for I in Base.Flexes.Flex_Vertedge'Range loop
            Base.Flexes.Flex_Vertedge (I) := Source.Flexes.Flex_Vertedge (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Edge /= null then
         for I in Base.Flexes.Flex_Edge'Range loop
            Base.Flexes.Flex_Edge (I) := Source.Flexes.Flex_Edge (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Edgeflap /= null then
         for I in Base.Flexes.Flex_Edgeflap'Range loop
            Base.Flexes.Flex_Edgeflap (I) := Source.Flexes.Flex_Edgeflap (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elem /= null then
         for I in Base.Flexes.Flex_Elem'Range loop
            Base.Flexes.Flex_Elem (I) := Source.Flexes.Flex_Elem (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elemtexcoord /= null then
         for I in Base.Flexes.Flex_Elemtexcoord'Range loop
            Base.Flexes.Flex_Elemtexcoord (I) := Source.Flexes.Flex_Elemtexcoord (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elemedge /= null then
         for I in Base.Flexes.Flex_Elemedge'Range loop
            Base.Flexes.Flex_Elemedge (I) := Source.Flexes.Flex_Elemedge (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Elemlayer /= null then
         for I in Base.Flexes.Flex_Elemlayer'Range loop
            Base.Flexes.Flex_Elemlayer (I) := Source.Flexes.Flex_Elemlayer (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Shell /= null then
         for I in Base.Flexes.Flex_Shell'Range loop
            Base.Flexes.Flex_Shell (I) := Source.Flexes.Flex_Shell (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Evpair /= null then
         for I in Base.Flexes.Flex_Evpair'Range loop
            Base.Flexes.Flex_Evpair (I) := Source.Flexes.Flex_Evpair (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vert /= null then
         for I in Base.Flexes.Flex_Vert'Range loop
            Base.Flexes.Flex_Vert (I) := Source.Flexes.Flex_Vert (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vert0 /= null then
         for I in Base.Flexes.Flex_Vert0'Range loop
            Base.Flexes.Flex_Vert0 (I) := Source.Flexes.Flex_Vert0 (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Vertmetric /= null then
         for I in Base.Flexes.Flex_Vertmetric'Range loop
            Base.Flexes.Flex_Vertmetric (I) := Source.Flexes.Flex_Vertmetric (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Node /= null then
         for I in Base.Flexes.Flex_Node'Range loop
            Base.Flexes.Flex_Node (I) := Source.Flexes.Flex_Node (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Node0 /= null then
         for I in Base.Flexes.Flex_Node0'Range loop
            Base.Flexes.Flex_Node0 (I) := Source.Flexes.Flex_Node0 (I);
         end loop;
      end if;
      if Base.Flexes.Flexedge_Length0 /= null then
         for I in Base.Flexes.Flexedge_Length0'Range loop
            Base.Flexes.Flexedge_Length0 (I) := Source.Flexes.Flexedge_Length0 (I);
         end loop;
      end if;
      if Base.Flexes.Flexedge_Invweight0 /= null then
         for I in Base.Flexes.Flexedge_Invweight0'Range loop
            Base.Flexes.Flexedge_Invweight0 (I) := Source.Flexes.Flexedge_Invweight0 (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Radius /= null then
         for I in Base.Flexes.Flex_Radius'Range loop
            Base.Flexes.Flex_Radius (I) := Source.Flexes.Flex_Radius (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Size /= null then
         for I in Base.Flexes.Flex_Size'Range loop
            Base.Flexes.Flex_Size (I) := Source.Flexes.Flex_Size (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Stiffness /= null then
         for I in Base.Flexes.Flex_Stiffness'Range loop
            Base.Flexes.Flex_Stiffness (I) := Source.Flexes.Flex_Stiffness (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Bending /= null then
         for I in Base.Flexes.Flex_Bending'Range loop
            Base.Flexes.Flex_Bending (I) := Source.Flexes.Flex_Bending (I);
         end loop;
      end if;
      if Base.Flexes.Efm0_Dofid /= null then
         for I in Base.Flexes.Efm0_Dofid'Range loop
            Base.Flexes.Efm0_Dofid (I) := Source.Flexes.Efm0_Dofid (I);
         end loop;
      end if;
      if Base.Flexes.Efm0_L_Rownnz /= null then
         for I in Base.Flexes.Efm0_L_Rownnz'Range loop
            Base.Flexes.Efm0_L_Rownnz (I) := Source.Flexes.Efm0_L_Rownnz (I);
         end loop;
      end if;
      if Base.Flexes.Efm0_L_Rowadr /= null then
         for I in Base.Flexes.Efm0_L_Rowadr'Range loop
            Base.Flexes.Efm0_L_Rowadr (I) := Source.Flexes.Efm0_L_Rowadr (I);
         end loop;
      end if;
      if Base.Flexes.Efm0_L_Colind /= null then
         for I in Base.Flexes.Efm0_L_Colind'Range loop
            Base.Flexes.Efm0_L_Colind (I) := Source.Flexes.Efm0_L_Colind (I);
         end loop;
      end if;
      if Base.Flexes.Efm0_L /= null then
         for I in Base.Flexes.Efm0_L'Range loop
            Base.Flexes.Efm0_L (I) := Source.Flexes.Efm0_L (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Damping /= null then
         for I in Base.Flexes.Flex_Damping'Range loop
            Base.Flexes.Flex_Damping (I) := Source.Flexes.Flex_Damping (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Edgestiffness /= null then
         for I in Base.Flexes.Flex_Edgestiffness'Range loop
            Base.Flexes.Flex_Edgestiffness (I) := Source.Flexes.Flex_Edgestiffness (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Edgedamping /= null then
         for I in Base.Flexes.Flex_Edgedamping'Range loop
            Base.Flexes.Flex_Edgedamping (I) := Source.Flexes.Flex_Edgedamping (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Edgeequality /= null then
         for I in Base.Flexes.Flex_Edgeequality'Range loop
            Base.Flexes.Flex_Edgeequality (I) := Source.Flexes.Flex_Edgeequality (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Rigid /= null then
         for I in Base.Flexes.Flex_Rigid'Range loop
            Base.Flexes.Flex_Rigid (I) := Source.Flexes.Flex_Rigid (I);
         end loop;
      end if;
      if Base.Flexes.Flexedge_Rigid /= null then
         for I in Base.Flexes.Flexedge_Rigid'Range loop
            Base.Flexes.Flexedge_Rigid (I) := Source.Flexes.Flexedge_Rigid (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Centered /= null then
         for I in Base.Flexes.Flex_Centered'Range loop
            Base.Flexes.Flex_Centered (I) := Source.Flexes.Flex_Centered (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Flatskin /= null then
         for I in Base.Flexes.Flex_Flatskin'Range loop
            Base.Flexes.Flex_Flatskin (I) := Source.Flexes.Flex_Flatskin (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Bvhadr /= null then
         for I in Base.Flexes.Flex_Bvhadr'Range loop
            Base.Flexes.Flex_Bvhadr (I) := Source.Flexes.Flex_Bvhadr (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Bvhnum /= null then
         for I in Base.Flexes.Flex_Bvhnum'Range loop
            Base.Flexes.Flex_Bvhnum (I) := Source.Flexes.Flex_Bvhnum (I);
         end loop;
      end if;
      if Base.Flexes.Flexedge_J_Rownnz /= null then
         for I in Base.Flexes.Flexedge_J_Rownnz'Range loop
            Base.Flexes.Flexedge_J_Rownnz (I) := Source.Flexes.Flexedge_J_Rownnz (I);
         end loop;
      end if;
      if Base.Flexes.Flexedge_J_Rowadr /= null then
         for I in Base.Flexes.Flexedge_J_Rowadr'Range loop
            Base.Flexes.Flexedge_J_Rowadr (I) := Source.Flexes.Flexedge_J_Rowadr (I);
         end loop;
      end if;
      if Base.Flexes.Flexedge_J_Colind /= null then
         for I in Base.Flexes.Flexedge_J_Colind'Range loop
            Base.Flexes.Flexedge_J_Colind (I) := Source.Flexes.Flexedge_J_Colind (I);
         end loop;
      end if;
      if Base.Flexes.Flexvert_J_Rownnz /= null then
         for I in Base.Flexes.Flexvert_J_Rownnz'Range loop
            Base.Flexes.Flexvert_J_Rownnz (I) := Source.Flexes.Flexvert_J_Rownnz (I);
         end loop;
      end if;
      if Base.Flexes.Flexvert_J_Rowadr /= null then
         for I in Base.Flexes.Flexvert_J_Rowadr'Range loop
            Base.Flexes.Flexvert_J_Rowadr (I) := Source.Flexes.Flexvert_J_Rowadr (I);
         end loop;
      end if;
      if Base.Flexes.Flexvert_J_Colind /= null then
         for I in Base.Flexes.Flexvert_J_Colind'Range loop
            Base.Flexes.Flexvert_J_Colind (I) := Source.Flexes.Flexvert_J_Colind (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Rgba /= null then
         for I in Base.Flexes.Flex_Rgba'Range loop
            Base.Flexes.Flex_Rgba (I) := Source.Flexes.Flex_Rgba (I);
         end loop;
      end if;
      if Base.Flexes.Flex_Texcoord /= null then
         for I in Base.Flexes.Flex_Texcoord'Range loop
            Base.Flexes.Flex_Texcoord (I) := Source.Flexes.Flex_Texcoord (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Vertadr /= null then
         for I in Base.Meshes.Mesh_Vertadr'Range loop
            Base.Meshes.Mesh_Vertadr (I) := Source.Meshes.Mesh_Vertadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Vertnum /= null then
         for I in Base.Meshes.Mesh_Vertnum'Range loop
            Base.Meshes.Mesh_Vertnum (I) := Source.Meshes.Mesh_Vertnum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Faceadr /= null then
         for I in Base.Meshes.Mesh_Faceadr'Range loop
            Base.Meshes.Mesh_Faceadr (I) := Source.Meshes.Mesh_Faceadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Facenum /= null then
         for I in Base.Meshes.Mesh_Facenum'Range loop
            Base.Meshes.Mesh_Facenum (I) := Source.Meshes.Mesh_Facenum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Bvhadr /= null then
         for I in Base.Meshes.Mesh_Bvhadr'Range loop
            Base.Meshes.Mesh_Bvhadr (I) := Source.Meshes.Mesh_Bvhadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Bvhnum /= null then
         for I in Base.Meshes.Mesh_Bvhnum'Range loop
            Base.Meshes.Mesh_Bvhnum (I) := Source.Meshes.Mesh_Bvhnum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Octadr /= null then
         for I in Base.Meshes.Mesh_Octadr'Range loop
            Base.Meshes.Mesh_Octadr (I) := Source.Meshes.Mesh_Octadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Octnum /= null then
         for I in Base.Meshes.Mesh_Octnum'Range loop
            Base.Meshes.Mesh_Octnum (I) := Source.Meshes.Mesh_Octnum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Normaladr /= null then
         for I in Base.Meshes.Mesh_Normaladr'Range loop
            Base.Meshes.Mesh_Normaladr (I) := Source.Meshes.Mesh_Normaladr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Normalnum /= null then
         for I in Base.Meshes.Mesh_Normalnum'Range loop
            Base.Meshes.Mesh_Normalnum (I) := Source.Meshes.Mesh_Normalnum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Texcoordadr /= null then
         for I in Base.Meshes.Mesh_Texcoordadr'Range loop
            Base.Meshes.Mesh_Texcoordadr (I) := Source.Meshes.Mesh_Texcoordadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Texcoordnum /= null then
         for I in Base.Meshes.Mesh_Texcoordnum'Range loop
            Base.Meshes.Mesh_Texcoordnum (I) := Source.Meshes.Mesh_Texcoordnum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Graphadr /= null then
         for I in Base.Meshes.Mesh_Graphadr'Range loop
            Base.Meshes.Mesh_Graphadr (I) := Source.Meshes.Mesh_Graphadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Extrema /= null then
         for I in Base.Meshes.Mesh_Extrema'Range loop
            Base.Meshes.Mesh_Extrema (I) := Source.Meshes.Mesh_Extrema (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Vert /= null then
         for I in Base.Meshes.Mesh_Vert'Range loop
            Base.Meshes.Mesh_Vert (I) := Source.Meshes.Mesh_Vert (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Normal /= null then
         for I in Base.Meshes.Mesh_Normal'Range loop
            Base.Meshes.Mesh_Normal (I) := Source.Meshes.Mesh_Normal (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Texcoord /= null then
         for I in Base.Meshes.Mesh_Texcoord'Range loop
            Base.Meshes.Mesh_Texcoord (I) := Source.Meshes.Mesh_Texcoord (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Face /= null then
         for I in Base.Meshes.Mesh_Face'Range loop
            Base.Meshes.Mesh_Face (I) := Source.Meshes.Mesh_Face (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Facenormal /= null then
         for I in Base.Meshes.Mesh_Facenormal'Range loop
            Base.Meshes.Mesh_Facenormal (I) := Source.Meshes.Mesh_Facenormal (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Facetexcoord /= null then
         for I in Base.Meshes.Mesh_Facetexcoord'Range loop
            Base.Meshes.Mesh_Facetexcoord (I) := Source.Meshes.Mesh_Facetexcoord (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Graph /= null then
         for I in Base.Meshes.Mesh_Graph'Range loop
            Base.Meshes.Mesh_Graph (I) := Source.Meshes.Mesh_Graph (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Scale /= null then
         for I in Base.Meshes.Mesh_Scale'Range loop
            Base.Meshes.Mesh_Scale (I) := Source.Meshes.Mesh_Scale (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Pos /= null then
         for I in Base.Meshes.Mesh_Pos'Range loop
            Base.Meshes.Mesh_Pos (I) := Source.Meshes.Mesh_Pos (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Quat /= null then
         for I in Base.Meshes.Mesh_Quat'Range loop
            Base.Meshes.Mesh_Quat (I) := Source.Meshes.Mesh_Quat (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Pathadr /= null then
         for I in Base.Meshes.Mesh_Pathadr'Range loop
            Base.Meshes.Mesh_Pathadr (I) := Source.Meshes.Mesh_Pathadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polynum /= null then
         for I in Base.Meshes.Mesh_Polynum'Range loop
            Base.Meshes.Mesh_Polynum (I) := Source.Meshes.Mesh_Polynum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polyadr /= null then
         for I in Base.Meshes.Mesh_Polyadr'Range loop
            Base.Meshes.Mesh_Polyadr (I) := Source.Meshes.Mesh_Polyadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polynormal /= null then
         for I in Base.Meshes.Mesh_Polynormal'Range loop
            Base.Meshes.Mesh_Polynormal (I) := Source.Meshes.Mesh_Polynormal (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polyvertadr /= null then
         for I in Base.Meshes.Mesh_Polyvertadr'Range loop
            Base.Meshes.Mesh_Polyvertadr (I) := Source.Meshes.Mesh_Polyvertadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polyvertnum /= null then
         for I in Base.Meshes.Mesh_Polyvertnum'Range loop
            Base.Meshes.Mesh_Polyvertnum (I) := Source.Meshes.Mesh_Polyvertnum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polyvert /= null then
         for I in Base.Meshes.Mesh_Polyvert'Range loop
            Base.Meshes.Mesh_Polyvert (I) := Source.Meshes.Mesh_Polyvert (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polymapadr /= null then
         for I in Base.Meshes.Mesh_Polymapadr'Range loop
            Base.Meshes.Mesh_Polymapadr (I) := Source.Meshes.Mesh_Polymapadr (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polymapnum /= null then
         for I in Base.Meshes.Mesh_Polymapnum'Range loop
            Base.Meshes.Mesh_Polymapnum (I) := Source.Meshes.Mesh_Polymapnum (I);
         end loop;
      end if;
      if Base.Meshes.Mesh_Polymap /= null then
         for I in Base.Meshes.Mesh_Polymap'Range loop
            Base.Meshes.Mesh_Polymap (I) := Source.Meshes.Mesh_Polymap (I);
         end loop;
      end if;
      if Base.Skins.Skin_Matid /= null then
         for I in Base.Skins.Skin_Matid'Range loop
            Base.Skins.Skin_Matid (I) := Source.Skins.Skin_Matid (I);
         end loop;
      end if;
      if Base.Skins.Skin_Group /= null then
         for I in Base.Skins.Skin_Group'Range loop
            Base.Skins.Skin_Group (I) := Source.Skins.Skin_Group (I);
         end loop;
      end if;
      if Base.Skins.Skin_Rgba /= null then
         for I in Base.Skins.Skin_Rgba'Range loop
            Base.Skins.Skin_Rgba (I) := Source.Skins.Skin_Rgba (I);
         end loop;
      end if;
      if Base.Skins.Skin_Inflate /= null then
         for I in Base.Skins.Skin_Inflate'Range loop
            Base.Skins.Skin_Inflate (I) := Source.Skins.Skin_Inflate (I);
         end loop;
      end if;
      if Base.Skins.Skin_Vertadr /= null then
         for I in Base.Skins.Skin_Vertadr'Range loop
            Base.Skins.Skin_Vertadr (I) := Source.Skins.Skin_Vertadr (I);
         end loop;
      end if;
      if Base.Skins.Skin_Vertnum /= null then
         for I in Base.Skins.Skin_Vertnum'Range loop
            Base.Skins.Skin_Vertnum (I) := Source.Skins.Skin_Vertnum (I);
         end loop;
      end if;
      if Base.Skins.Skin_Texcoordadr /= null then
         for I in Base.Skins.Skin_Texcoordadr'Range loop
            Base.Skins.Skin_Texcoordadr (I) := Source.Skins.Skin_Texcoordadr (I);
         end loop;
      end if;
      if Base.Skins.Skin_Faceadr /= null then
         for I in Base.Skins.Skin_Faceadr'Range loop
            Base.Skins.Skin_Faceadr (I) := Source.Skins.Skin_Faceadr (I);
         end loop;
      end if;
      if Base.Skins.Skin_Facenum /= null then
         for I in Base.Skins.Skin_Facenum'Range loop
            Base.Skins.Skin_Facenum (I) := Source.Skins.Skin_Facenum (I);
         end loop;
      end if;
      if Base.Skins.Skin_Boneadr /= null then
         for I in Base.Skins.Skin_Boneadr'Range loop
            Base.Skins.Skin_Boneadr (I) := Source.Skins.Skin_Boneadr (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonenum /= null then
         for I in Base.Skins.Skin_Bonenum'Range loop
            Base.Skins.Skin_Bonenum (I) := Source.Skins.Skin_Bonenum (I);
         end loop;
      end if;
      if Base.Skins.Skin_Vert /= null then
         for I in Base.Skins.Skin_Vert'Range loop
            Base.Skins.Skin_Vert (I) := Source.Skins.Skin_Vert (I);
         end loop;
      end if;
      if Base.Skins.Skin_Texcoord /= null then
         for I in Base.Skins.Skin_Texcoord'Range loop
            Base.Skins.Skin_Texcoord (I) := Source.Skins.Skin_Texcoord (I);
         end loop;
      end if;
      if Base.Skins.Skin_Face /= null then
         for I in Base.Skins.Skin_Face'Range loop
            Base.Skins.Skin_Face (I) := Source.Skins.Skin_Face (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonevertadr /= null then
         for I in Base.Skins.Skin_Bonevertadr'Range loop
            Base.Skins.Skin_Bonevertadr (I) := Source.Skins.Skin_Bonevertadr (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonevertnum /= null then
         for I in Base.Skins.Skin_Bonevertnum'Range loop
            Base.Skins.Skin_Bonevertnum (I) := Source.Skins.Skin_Bonevertnum (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonebindpos /= null then
         for I in Base.Skins.Skin_Bonebindpos'Range loop
            Base.Skins.Skin_Bonebindpos (I) := Source.Skins.Skin_Bonebindpos (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonebindquat /= null then
         for I in Base.Skins.Skin_Bonebindquat'Range loop
            Base.Skins.Skin_Bonebindquat (I) := Source.Skins.Skin_Bonebindquat (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonebodyid /= null then
         for I in Base.Skins.Skin_Bonebodyid'Range loop
            Base.Skins.Skin_Bonebodyid (I) := Source.Skins.Skin_Bonebodyid (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonevertid /= null then
         for I in Base.Skins.Skin_Bonevertid'Range loop
            Base.Skins.Skin_Bonevertid (I) := Source.Skins.Skin_Bonevertid (I);
         end loop;
      end if;
      if Base.Skins.Skin_Bonevertweight /= null then
         for I in Base.Skins.Skin_Bonevertweight'Range loop
            Base.Skins.Skin_Bonevertweight (I) := Source.Skins.Skin_Bonevertweight (I);
         end loop;
      end if;
      if Base.Skins.Skin_Pathadr /= null then
         for I in Base.Skins.Skin_Pathadr'Range loop
            Base.Skins.Skin_Pathadr (I) := Source.Skins.Skin_Pathadr (I);
         end loop;
      end if;
      if Base.Hfields.Hfield_Size /= null then
         for I in Base.Hfields.Hfield_Size'Range loop
            Base.Hfields.Hfield_Size (I) := Source.Hfields.Hfield_Size (I);
         end loop;
      end if;
      if Base.Hfields.Hfield_Nrow /= null then
         for I in Base.Hfields.Hfield_Nrow'Range loop
            Base.Hfields.Hfield_Nrow (I) := Source.Hfields.Hfield_Nrow (I);
         end loop;
      end if;
      if Base.Hfields.Hfield_Ncol /= null then
         for I in Base.Hfields.Hfield_Ncol'Range loop
            Base.Hfields.Hfield_Ncol (I) := Source.Hfields.Hfield_Ncol (I);
         end loop;
      end if;
      if Base.Hfields.Hfield_Adr /= null then
         for I in Base.Hfields.Hfield_Adr'Range loop
            Base.Hfields.Hfield_Adr (I) := Source.Hfields.Hfield_Adr (I);
         end loop;
      end if;
      if Base.Hfields.Hfield_Data /= null then
         for I in Base.Hfields.Hfield_Data'Range loop
            Base.Hfields.Hfield_Data (I) := Source.Hfields.Hfield_Data (I);
         end loop;
      end if;
      if Base.Hfields.Hfield_Pathadr /= null then
         for I in Base.Hfields.Hfield_Pathadr'Range loop
            Base.Hfields.Hfield_Pathadr (I) := Source.Hfields.Hfield_Pathadr (I);
         end loop;
      end if;
      if Base.Textures.Tex_Type /= null then
         for I in Base.Textures.Tex_Type'Range loop
            Base.Textures.Tex_Type (I) := Source.Textures.Tex_Type (I);
         end loop;
      end if;
      if Base.Textures.Tex_Colorspace /= null then
         for I in Base.Textures.Tex_Colorspace'Range loop
            Base.Textures.Tex_Colorspace (I) := Source.Textures.Tex_Colorspace (I);
         end loop;
      end if;
      if Base.Textures.Tex_Height /= null then
         for I in Base.Textures.Tex_Height'Range loop
            Base.Textures.Tex_Height (I) := Source.Textures.Tex_Height (I);
         end loop;
      end if;
      if Base.Textures.Tex_Width /= null then
         for I in Base.Textures.Tex_Width'Range loop
            Base.Textures.Tex_Width (I) := Source.Textures.Tex_Width (I);
         end loop;
      end if;
      if Base.Textures.Tex_Nchannel /= null then
         for I in Base.Textures.Tex_Nchannel'Range loop
            Base.Textures.Tex_Nchannel (I) := Source.Textures.Tex_Nchannel (I);
         end loop;
      end if;
      if Base.Textures.Tex_Adr /= null then
         for I in Base.Textures.Tex_Adr'Range loop
            Base.Textures.Tex_Adr (I) := Source.Textures.Tex_Adr (I);
         end loop;
      end if;
      if Base.Textures.Tex_Data /= null then
         for I in Base.Textures.Tex_Data'Range loop
            Base.Textures.Tex_Data (I) := Source.Textures.Tex_Data (I);
         end loop;
      end if;
      if Base.Textures.Tex_Pathadr /= null then
         for I in Base.Textures.Tex_Pathadr'Range loop
            Base.Textures.Tex_Pathadr (I) := Source.Textures.Tex_Pathadr (I);
         end loop;
      end if;
      if Base.Materials.Mat_Texid /= null then
         for I in Base.Materials.Mat_Texid'Range loop
            Base.Materials.Mat_Texid (I) := Source.Materials.Mat_Texid (I);
         end loop;
      end if;
      if Base.Materials.Mat_Texuniform /= null then
         for I in Base.Materials.Mat_Texuniform'Range loop
            Base.Materials.Mat_Texuniform (I) := Source.Materials.Mat_Texuniform (I);
         end loop;
      end if;
      if Base.Materials.Mat_Texrepeat /= null then
         for I in Base.Materials.Mat_Texrepeat'Range loop
            Base.Materials.Mat_Texrepeat (I) := Source.Materials.Mat_Texrepeat (I);
         end loop;
      end if;
      if Base.Materials.Mat_Emission /= null then
         for I in Base.Materials.Mat_Emission'Range loop
            Base.Materials.Mat_Emission (I) := Source.Materials.Mat_Emission (I);
         end loop;
      end if;
      if Base.Materials.Mat_Specular /= null then
         for I in Base.Materials.Mat_Specular'Range loop
            Base.Materials.Mat_Specular (I) := Source.Materials.Mat_Specular (I);
         end loop;
      end if;
      if Base.Materials.Mat_Shininess /= null then
         for I in Base.Materials.Mat_Shininess'Range loop
            Base.Materials.Mat_Shininess (I) := Source.Materials.Mat_Shininess (I);
         end loop;
      end if;
      if Base.Materials.Mat_Reflectance /= null then
         for I in Base.Materials.Mat_Reflectance'Range loop
            Base.Materials.Mat_Reflectance (I) := Source.Materials.Mat_Reflectance (I);
         end loop;
      end if;
      if Base.Materials.Mat_Metallic /= null then
         for I in Base.Materials.Mat_Metallic'Range loop
            Base.Materials.Mat_Metallic (I) := Source.Materials.Mat_Metallic (I);
         end loop;
      end if;
      if Base.Materials.Mat_Roughness /= null then
         for I in Base.Materials.Mat_Roughness'Range loop
            Base.Materials.Mat_Roughness (I) := Source.Materials.Mat_Roughness (I);
         end loop;
      end if;
      if Base.Materials.Mat_Rgba /= null then
         for I in Base.Materials.Mat_Rgba'Range loop
            Base.Materials.Mat_Rgba (I) := Source.Materials.Mat_Rgba (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Dim /= null then
         for I in Base.Pairs.Pair_Dim'Range loop
            Base.Pairs.Pair_Dim (I) := Source.Pairs.Pair_Dim (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Geom1 /= null then
         for I in Base.Pairs.Pair_Geom1'Range loop
            Base.Pairs.Pair_Geom1 (I) := Source.Pairs.Pair_Geom1 (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Geom2 /= null then
         for I in Base.Pairs.Pair_Geom2'Range loop
            Base.Pairs.Pair_Geom2 (I) := Source.Pairs.Pair_Geom2 (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Signature /= null then
         for I in Base.Pairs.Pair_Signature'Range loop
            Base.Pairs.Pair_Signature (I) := Source.Pairs.Pair_Signature (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Solref /= null then
         for I in Base.Pairs.Pair_Solref'Range loop
            Base.Pairs.Pair_Solref (I) := Source.Pairs.Pair_Solref (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Solreffriction /= null then
         for I in Base.Pairs.Pair_Solreffriction'Range loop
            Base.Pairs.Pair_Solreffriction (I) := Source.Pairs.Pair_Solreffriction (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Solimp /= null then
         for I in Base.Pairs.Pair_Solimp'Range loop
            Base.Pairs.Pair_Solimp (I) := Source.Pairs.Pair_Solimp (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Margin /= null then
         for I in Base.Pairs.Pair_Margin'Range loop
            Base.Pairs.Pair_Margin (I) := Source.Pairs.Pair_Margin (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Gap /= null then
         for I in Base.Pairs.Pair_Gap'Range loop
            Base.Pairs.Pair_Gap (I) := Source.Pairs.Pair_Gap (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Adhesion /= null then
         for I in Base.Pairs.Pair_Adhesion'Range loop
            Base.Pairs.Pair_Adhesion (I) := Source.Pairs.Pair_Adhesion (I);
         end loop;
      end if;
      if Base.Pairs.Pair_Friction /= null then
         for I in Base.Pairs.Pair_Friction'Range loop
            Base.Pairs.Pair_Friction (I) := Source.Pairs.Pair_Friction (I);
         end loop;
      end if;
      if Base.Excludes.Exclude_Signature /= null then
         for I in Base.Excludes.Exclude_Signature'Range loop
            Base.Excludes.Exclude_Signature (I) := Source.Excludes.Exclude_Signature (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Type /= null then
         for I in Base.Equalities.Eq_Type'Range loop
            Base.Equalities.Eq_Type (I) := Source.Equalities.Eq_Type (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Obj1id /= null then
         for I in Base.Equalities.Eq_Obj1id'Range loop
            Base.Equalities.Eq_Obj1id (I) := Source.Equalities.Eq_Obj1id (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Obj2id /= null then
         for I in Base.Equalities.Eq_Obj2id'Range loop
            Base.Equalities.Eq_Obj2id (I) := Source.Equalities.Eq_Obj2id (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Objtype /= null then
         for I in Base.Equalities.Eq_Objtype'Range loop
            Base.Equalities.Eq_Objtype (I) := Source.Equalities.Eq_Objtype (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Active0 /= null then
         for I in Base.Equalities.Eq_Active0'Range loop
            Base.Equalities.Eq_Active0 (I) := Source.Equalities.Eq_Active0 (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Solref /= null then
         for I in Base.Equalities.Eq_Solref'Range loop
            Base.Equalities.Eq_Solref (I) := Source.Equalities.Eq_Solref (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Solimp /= null then
         for I in Base.Equalities.Eq_Solimp'Range loop
            Base.Equalities.Eq_Solimp (I) := Source.Equalities.Eq_Solimp (I);
         end loop;
      end if;
      if Base.Equalities.Eq_Data /= null then
         for I in Base.Equalities.Eq_Data'Range loop
            Base.Equalities.Eq_Data (I) := Source.Equalities.Eq_Data (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Adr /= null then
         for I in Base.Tendons.Tendon_Adr'Range loop
            Base.Tendons.Tendon_Adr (I) := Source.Tendons.Tendon_Adr (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Num /= null then
         for I in Base.Tendons.Tendon_Num'Range loop
            Base.Tendons.Tendon_Num (I) := Source.Tendons.Tendon_Num (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Matid /= null then
         for I in Base.Tendons.Tendon_Matid'Range loop
            Base.Tendons.Tendon_Matid (I) := Source.Tendons.Tendon_Matid (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Actuatorid /= null then
         for I in Base.Tendons.Tendon_Actuatorid'Range loop
            Base.Tendons.Tendon_Actuatorid (I) := Source.Tendons.Tendon_Actuatorid (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Group /= null then
         for I in Base.Tendons.Tendon_Group'Range loop
            Base.Tendons.Tendon_Group (I) := Source.Tendons.Tendon_Group (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Treenum /= null then
         for I in Base.Tendons.Tendon_Treenum'Range loop
            Base.Tendons.Tendon_Treenum (I) := Source.Tendons.Tendon_Treenum (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Treeid /= null then
         for I in Base.Tendons.Tendon_Treeid'Range loop
            Base.Tendons.Tendon_Treeid (I) := Source.Tendons.Tendon_Treeid (I);
         end loop;
      end if;
      if Base.Tendons.Ten_J_Rownnz /= null then
         for I in Base.Tendons.Ten_J_Rownnz'Range loop
            Base.Tendons.Ten_J_Rownnz (I) := Source.Tendons.Ten_J_Rownnz (I);
         end loop;
      end if;
      if Base.Tendons.Ten_J_Rowadr /= null then
         for I in Base.Tendons.Ten_J_Rowadr'Range loop
            Base.Tendons.Ten_J_Rowadr (I) := Source.Tendons.Ten_J_Rowadr (I);
         end loop;
      end if;
      if Base.Tendons.Ten_J_Colind /= null then
         for I in Base.Tendons.Ten_J_Colind'Range loop
            Base.Tendons.Ten_J_Colind (I) := Source.Tendons.Ten_J_Colind (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Limited /= null then
         for I in Base.Tendons.Tendon_Limited'Range loop
            Base.Tendons.Tendon_Limited (I) := Source.Tendons.Tendon_Limited (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Actfrclimited /= null then
         for I in Base.Tendons.Tendon_Actfrclimited'Range loop
            Base.Tendons.Tendon_Actfrclimited (I) := Source.Tendons.Tendon_Actfrclimited (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Width /= null then
         for I in Base.Tendons.Tendon_Width'Range loop
            Base.Tendons.Tendon_Width (I) := Source.Tendons.Tendon_Width (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Solref_Lim /= null then
         for I in Base.Tendons.Tendon_Solref_Lim'Range loop
            Base.Tendons.Tendon_Solref_Lim (I) := Source.Tendons.Tendon_Solref_Lim (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Solimp_Lim /= null then
         for I in Base.Tendons.Tendon_Solimp_Lim'Range loop
            Base.Tendons.Tendon_Solimp_Lim (I) := Source.Tendons.Tendon_Solimp_Lim (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Solref_Fri /= null then
         for I in Base.Tendons.Tendon_Solref_Fri'Range loop
            Base.Tendons.Tendon_Solref_Fri (I) := Source.Tendons.Tendon_Solref_Fri (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Solimp_Fri /= null then
         for I in Base.Tendons.Tendon_Solimp_Fri'Range loop
            Base.Tendons.Tendon_Solimp_Fri (I) := Source.Tendons.Tendon_Solimp_Fri (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Range /= null then
         for I in Base.Tendons.Tendon_Range'Range loop
            Base.Tendons.Tendon_Range (I) := Source.Tendons.Tendon_Range (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Actfrcrange /= null then
         for I in Base.Tendons.Tendon_Actfrcrange'Range loop
            Base.Tendons.Tendon_Actfrcrange (I) := Source.Tendons.Tendon_Actfrcrange (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Margin /= null then
         for I in Base.Tendons.Tendon_Margin'Range loop
            Base.Tendons.Tendon_Margin (I) := Source.Tendons.Tendon_Margin (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Stiffness /= null then
         for I in Base.Tendons.Tendon_Stiffness'Range loop
            Base.Tendons.Tendon_Stiffness (I) := Source.Tendons.Tendon_Stiffness (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Stiffnesspoly /= null then
         for I in Base.Tendons.Tendon_Stiffnesspoly'Range loop
            Base.Tendons.Tendon_Stiffnesspoly (I) := Source.Tendons.Tendon_Stiffnesspoly (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Damping /= null then
         for I in Base.Tendons.Tendon_Damping'Range loop
            Base.Tendons.Tendon_Damping (I) := Source.Tendons.Tendon_Damping (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Dampingpoly /= null then
         for I in Base.Tendons.Tendon_Dampingpoly'Range loop
            Base.Tendons.Tendon_Dampingpoly (I) := Source.Tendons.Tendon_Dampingpoly (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Armature /= null then
         for I in Base.Tendons.Tendon_Armature'Range loop
            Base.Tendons.Tendon_Armature (I) := Source.Tendons.Tendon_Armature (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Frictionloss /= null then
         for I in Base.Tendons.Tendon_Frictionloss'Range loop
            Base.Tendons.Tendon_Frictionloss (I) := Source.Tendons.Tendon_Frictionloss (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Lengthspring /= null then
         for I in Base.Tendons.Tendon_Lengthspring'Range loop
            Base.Tendons.Tendon_Lengthspring (I) := Source.Tendons.Tendon_Lengthspring (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Length0 /= null then
         for I in Base.Tendons.Tendon_Length0'Range loop
            Base.Tendons.Tendon_Length0 (I) := Source.Tendons.Tendon_Length0 (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Invweight0 /= null then
         for I in Base.Tendons.Tendon_Invweight0'Range loop
            Base.Tendons.Tendon_Invweight0 (I) := Source.Tendons.Tendon_Invweight0 (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_User /= null then
         for I in Base.Tendons.Tendon_User'Range loop
            Base.Tendons.Tendon_User (I) := Source.Tendons.Tendon_User (I);
         end loop;
      end if;
      if Base.Tendons.Tendon_Rgba /= null then
         for I in Base.Tendons.Tendon_Rgba'Range loop
            Base.Tendons.Tendon_Rgba (I) := Source.Tendons.Tendon_Rgba (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Trntype /= null then
         for I in Base.Actuators.Actuator_Trntype'Range loop
            Base.Actuators.Actuator_Trntype (I) := Source.Actuators.Actuator_Trntype (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Dyntype /= null then
         for I in Base.Actuators.Actuator_Dyntype'Range loop
            Base.Actuators.Actuator_Dyntype (I) := Source.Actuators.Actuator_Dyntype (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Gaintype /= null then
         for I in Base.Actuators.Actuator_Gaintype'Range loop
            Base.Actuators.Actuator_Gaintype (I) := Source.Actuators.Actuator_Gaintype (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Biastype /= null then
         for I in Base.Actuators.Actuator_Biastype'Range loop
            Base.Actuators.Actuator_Biastype (I) := Source.Actuators.Actuator_Biastype (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Ctrladr /= null then
         for I in Base.Actuators.Actuator_Ctrladr'Range loop
            Base.Actuators.Actuator_Ctrladr (I) := Source.Actuators.Actuator_Ctrladr (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Ctrlnum /= null then
         for I in Base.Actuators.Actuator_Ctrlnum'Range loop
            Base.Actuators.Actuator_Ctrlnum (I) := Source.Actuators.Actuator_Ctrlnum (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Ctrlspec /= null then
         for I in Base.Actuators.Actuator_Ctrlspec'Range loop
            Base.Actuators.Actuator_Ctrlspec (I) := Source.Actuators.Actuator_Ctrlspec (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Outadr /= null then
         for I in Base.Actuators.Actuator_Outadr'Range loop
            Base.Actuators.Actuator_Outadr (I) := Source.Actuators.Actuator_Outadr (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Outnum /= null then
         for I in Base.Actuators.Actuator_Outnum'Range loop
            Base.Actuators.Actuator_Outnum (I) := Source.Actuators.Actuator_Outnum (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Actadr /= null then
         for I in Base.Actuators.Actuator_Actadr'Range loop
            Base.Actuators.Actuator_Actadr (I) := Source.Actuators.Actuator_Actadr (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Actnum /= null then
         for I in Base.Actuators.Actuator_Actnum'Range loop
            Base.Actuators.Actuator_Actnum (I) := Source.Actuators.Actuator_Actnum (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Trnid /= null then
         for I in Base.Actuators.Actuator_Trnid'Range loop
            Base.Actuators.Actuator_Trnid (I) := Source.Actuators.Actuator_Trnid (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Cranklength /= null then
         for I in Base.Actuators.Actuator_Cranklength'Range loop
            Base.Actuators.Actuator_Cranklength (I) := Source.Actuators.Actuator_Cranklength (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Dynprm /= null then
         for I in Base.Actuators.Actuator_Dynprm'Range loop
            Base.Actuators.Actuator_Dynprm (I) := Source.Actuators.Actuator_Dynprm (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Gainprm /= null then
         for I in Base.Actuators.Actuator_Gainprm'Range loop
            Base.Actuators.Actuator_Gainprm (I) := Source.Actuators.Actuator_Gainprm (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Biasprm /= null then
         for I in Base.Actuators.Actuator_Biasprm'Range loop
            Base.Actuators.Actuator_Biasprm (I) := Source.Actuators.Actuator_Biasprm (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Actlimited /= null then
         for I in Base.Actuators.Actuator_Actlimited'Range loop
            Base.Actuators.Actuator_Actlimited (I) := Source.Actuators.Actuator_Actlimited (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Actrange /= null then
         for I in Base.Actuators.Actuator_Actrange'Range loop
            Base.Actuators.Actuator_Actrange (I) := Source.Actuators.Actuator_Actrange (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Actearly /= null then
         for I in Base.Actuators.Actuator_Actearly'Range loop
            Base.Actuators.Actuator_Actearly (I) := Source.Actuators.Actuator_Actearly (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_History /= null then
         for I in Base.Actuators.Actuator_History'Range loop
            Base.Actuators.Actuator_History (I) := Source.Actuators.Actuator_History (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Historyadr /= null then
         for I in Base.Actuators.Actuator_Historyadr'Range loop
            Base.Actuators.Actuator_Historyadr (I) := Source.Actuators.Actuator_Historyadr (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Delay /= null then
         for I in Base.Actuators.Actuator_Delay'Range loop
            Base.Actuators.Actuator_Delay (I) := Source.Actuators.Actuator_Delay (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Damping /= null then
         for I in Base.Actuators.Actuator_Damping'Range loop
            Base.Actuators.Actuator_Damping (I) := Source.Actuators.Actuator_Damping (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Dampingpoly /= null then
         for I in Base.Actuators.Actuator_Dampingpoly'Range loop
            Base.Actuators.Actuator_Dampingpoly (I) := Source.Actuators.Actuator_Dampingpoly (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Armature /= null then
         for I in Base.Actuators.Actuator_Armature'Range loop
            Base.Actuators.Actuator_Armature (I) := Source.Actuators.Actuator_Armature (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Group /= null then
         for I in Base.Actuators.Actuator_Group'Range loop
            Base.Actuators.Actuator_Group (I) := Source.Actuators.Actuator_Group (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_User /= null then
         for I in Base.Actuators.Actuator_User'Range loop
            Base.Actuators.Actuator_User (I) := Source.Actuators.Actuator_User (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Plugin /= null then
         for I in Base.Actuators.Actuator_Plugin'Range loop
            Base.Actuators.Actuator_Plugin (I) := Source.Actuators.Actuator_Plugin (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Forcelimited /= null then
         for I in Base.Actuators.Actuator_Forcelimited'Range loop
            Base.Actuators.Actuator_Forcelimited (I) := Source.Actuators.Actuator_Forcelimited (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Forcerange /= null then
         for I in Base.Actuators.Actuator_Forcerange'Range loop
            Base.Actuators.Actuator_Forcerange (I) := Source.Actuators.Actuator_Forcerange (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Ctrllimited /= null then
         for I in Base.Actuators.Actuator_Ctrllimited'Range loop
            Base.Actuators.Actuator_Ctrllimited (I) := Source.Actuators.Actuator_Ctrllimited (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Ctrlrange /= null then
         for I in Base.Actuators.Actuator_Ctrlrange'Range loop
            Base.Actuators.Actuator_Ctrlrange (I) := Source.Actuators.Actuator_Ctrlrange (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Gear /= null then
         for I in Base.Actuators.Actuator_Gear'Range loop
            Base.Actuators.Actuator_Gear (I) := Source.Actuators.Actuator_Gear (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Acc0 /= null then
         for I in Base.Actuators.Actuator_Acc0'Range loop
            Base.Actuators.Actuator_Acc0 (I) := Source.Actuators.Actuator_Acc0 (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Length0 /= null then
         for I in Base.Actuators.Actuator_Length0'Range loop
            Base.Actuators.Actuator_Length0 (I) := Source.Actuators.Actuator_Length0 (I);
         end loop;
      end if;
      if Base.Actuators.Actuator_Lengthrange /= null then
         for I in Base.Actuators.Actuator_Lengthrange'Range loop
            Base.Actuators.Actuator_Lengthrange (I) := Source.Actuators.Actuator_Lengthrange (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Type /= null then
         for I in Base.Sensors.Sensor_Type'Range loop
            Base.Sensors.Sensor_Type (I) := Source.Sensors.Sensor_Type (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Datatype /= null then
         for I in Base.Sensors.Sensor_Datatype'Range loop
            Base.Sensors.Sensor_Datatype (I) := Source.Sensors.Sensor_Datatype (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Needstage /= null then
         for I in Base.Sensors.Sensor_Needstage'Range loop
            Base.Sensors.Sensor_Needstage (I) := Source.Sensors.Sensor_Needstage (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Objtype /= null then
         for I in Base.Sensors.Sensor_Objtype'Range loop
            Base.Sensors.Sensor_Objtype (I) := Source.Sensors.Sensor_Objtype (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Objid /= null then
         for I in Base.Sensors.Sensor_Objid'Range loop
            Base.Sensors.Sensor_Objid (I) := Source.Sensors.Sensor_Objid (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Reftype /= null then
         for I in Base.Sensors.Sensor_Reftype'Range loop
            Base.Sensors.Sensor_Reftype (I) := Source.Sensors.Sensor_Reftype (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Refid /= null then
         for I in Base.Sensors.Sensor_Refid'Range loop
            Base.Sensors.Sensor_Refid (I) := Source.Sensors.Sensor_Refid (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Intprm /= null then
         for I in Base.Sensors.Sensor_Intprm'Range loop
            Base.Sensors.Sensor_Intprm (I) := Source.Sensors.Sensor_Intprm (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Dim /= null then
         for I in Base.Sensors.Sensor_Dim'Range loop
            Base.Sensors.Sensor_Dim (I) := Source.Sensors.Sensor_Dim (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Adr /= null then
         for I in Base.Sensors.Sensor_Adr'Range loop
            Base.Sensors.Sensor_Adr (I) := Source.Sensors.Sensor_Adr (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Cutoff /= null then
         for I in Base.Sensors.Sensor_Cutoff'Range loop
            Base.Sensors.Sensor_Cutoff (I) := Source.Sensors.Sensor_Cutoff (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Noise /= null then
         for I in Base.Sensors.Sensor_Noise'Range loop
            Base.Sensors.Sensor_Noise (I) := Source.Sensors.Sensor_Noise (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_History /= null then
         for I in Base.Sensors.Sensor_History'Range loop
            Base.Sensors.Sensor_History (I) := Source.Sensors.Sensor_History (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Historyadr /= null then
         for I in Base.Sensors.Sensor_Historyadr'Range loop
            Base.Sensors.Sensor_Historyadr (I) := Source.Sensors.Sensor_Historyadr (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Delay /= null then
         for I in Base.Sensors.Sensor_Delay'Range loop
            Base.Sensors.Sensor_Delay (I) := Source.Sensors.Sensor_Delay (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Interval /= null then
         for I in Base.Sensors.Sensor_Interval'Range loop
            Base.Sensors.Sensor_Interval (I) := Source.Sensors.Sensor_Interval (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_User /= null then
         for I in Base.Sensors.Sensor_User'Range loop
            Base.Sensors.Sensor_User (I) := Source.Sensors.Sensor_User (I);
         end loop;
      end if;
      if Base.Sensors.Sensor_Plugin /= null then
         for I in Base.Sensors.Sensor_Plugin'Range loop
            Base.Sensors.Sensor_Plugin (I) := Source.Sensors.Sensor_Plugin (I);
         end loop;
      end if;
      if Base.Qpos.Qpos0 /= null then
         for I in Base.Qpos.Qpos0'Range loop
            Base.Qpos.Qpos0 (I) := Source.Qpos.Qpos0 (I);
         end loop;
      end if;
      if Base.Qpos.Qpos_Spring /= null then
         for I in Base.Qpos.Qpos_Spring'Range loop
            Base.Qpos.Qpos_Spring (I) := Source.Qpos.Qpos_Spring (I);
         end loop;
      end if;
      if Base.Bvh.Bvh_Depth /= null then
         for I in Base.Bvh.Bvh_Depth'Range loop
            Base.Bvh.Bvh_Depth (I) := Source.Bvh.Bvh_Depth (I);
         end loop;
      end if;
      if Base.Bvh.Bvh_Child /= null then
         for I in Base.Bvh.Bvh_Child'Range loop
            Base.Bvh.Bvh_Child (I) := Source.Bvh.Bvh_Child (I);
         end loop;
      end if;
      if Base.Bvh.Bvh_Nodeid /= null then
         for I in Base.Bvh.Bvh_Nodeid'Range loop
            Base.Bvh.Bvh_Nodeid (I) := Source.Bvh.Bvh_Nodeid (I);
         end loop;
      end if;
      if Base.Bvh.Bvh_Aabb /= null then
         for I in Base.Bvh.Bvh_Aabb'Range loop
            Base.Bvh.Bvh_Aabb (I) := Source.Bvh.Bvh_Aabb (I);
         end loop;
      end if;
      if Base.Bvh.Oct_Depth /= null then
         for I in Base.Bvh.Oct_Depth'Range loop
            Base.Bvh.Oct_Depth (I) := Source.Bvh.Oct_Depth (I);
         end loop;
      end if;
      if Base.Bvh.Oct_Child /= null then
         for I in Base.Bvh.Oct_Child'Range loop
            Base.Bvh.Oct_Child (I) := Source.Bvh.Oct_Child (I);
         end loop;
      end if;
      if Base.Bvh.Oct_Aabb /= null then
         for I in Base.Bvh.Oct_Aabb'Range loop
            Base.Bvh.Oct_Aabb (I) := Source.Bvh.Oct_Aabb (I);
         end loop;
      end if;
      if Base.Bvh.Oct_Coeff /= null then
         for I in Base.Bvh.Oct_Coeff'Range loop
            Base.Bvh.Oct_Coeff (I) := Source.Bvh.Oct_Coeff (I);
         end loop;
      end if;
      if Base.Wraps.Wrap_Type /= null then
         for I in Base.Wraps.Wrap_Type'Range loop
            Base.Wraps.Wrap_Type (I) := Source.Wraps.Wrap_Type (I);
         end loop;
      end if;
      if Base.Wraps.Wrap_Objid /= null then
         for I in Base.Wraps.Wrap_Objid'Range loop
            Base.Wraps.Wrap_Objid (I) := Source.Wraps.Wrap_Objid (I);
         end loop;
      end if;
      if Base.Wraps.Wrap_Prm /= null then
         for I in Base.Wraps.Wrap_Prm'Range loop
            Base.Wraps.Wrap_Prm (I) := Source.Wraps.Wrap_Prm (I);
         end loop;
      end if;
      if Base.Plugins.Plugin /= null then
         for I in Base.Plugins.Plugin'Range loop
            Base.Plugins.Plugin (I) := Source.Plugins.Plugin (I);
         end loop;
      end if;
      if Base.Plugins.Plugin_Stateadr /= null then
         for I in Base.Plugins.Plugin_Stateadr'Range loop
            Base.Plugins.Plugin_Stateadr (I) := Source.Plugins.Plugin_Stateadr (I);
         end loop;
      end if;
      if Base.Plugins.Plugin_Statenum /= null then
         for I in Base.Plugins.Plugin_Statenum'Range loop
            Base.Plugins.Plugin_Statenum (I) := Source.Plugins.Plugin_Statenum (I);
         end loop;
      end if;
      if Base.Plugins.Plugin_Attr /= null then
         for I in Base.Plugins.Plugin_Attr'Range loop
            Base.Plugins.Plugin_Attr (I) := Source.Plugins.Plugin_Attr (I);
         end loop;
      end if;
      if Base.Plugins.Plugin_Attradr /= null then
         for I in Base.Plugins.Plugin_Attradr'Range loop
            Base.Plugins.Plugin_Attradr (I) := Source.Plugins.Plugin_Attradr (I);
         end loop;
      end if;
      if Base.Numerics.Numeric_Adr /= null then
         for I in Base.Numerics.Numeric_Adr'Range loop
            Base.Numerics.Numeric_Adr (I) := Source.Numerics.Numeric_Adr (I);
         end loop;
      end if;
      if Base.Numerics.Numeric_Size /= null then
         for I in Base.Numerics.Numeric_Size'Range loop
            Base.Numerics.Numeric_Size (I) := Source.Numerics.Numeric_Size (I);
         end loop;
      end if;
      if Base.Numerics.Numeric_Data /= null then
         for I in Base.Numerics.Numeric_Data'Range loop
            Base.Numerics.Numeric_Data (I) := Source.Numerics.Numeric_Data (I);
         end loop;
      end if;
      if Base.Texts.Text_Adr /= null then
         for I in Base.Texts.Text_Adr'Range loop
            Base.Texts.Text_Adr (I) := Source.Texts.Text_Adr (I);
         end loop;
      end if;
      if Base.Texts.Text_Size /= null then
         for I in Base.Texts.Text_Size'Range loop
            Base.Texts.Text_Size (I) := Source.Texts.Text_Size (I);
         end loop;
      end if;
      if Base.Texts.Text_Data /= null then
         for I in Base.Texts.Text_Data'Range loop
            Base.Texts.Text_Data (I) := Source.Texts.Text_Data (I);
         end loop;
      end if;
      if Base.Tuples.Tuple_Adr /= null then
         for I in Base.Tuples.Tuple_Adr'Range loop
            Base.Tuples.Tuple_Adr (I) := Source.Tuples.Tuple_Adr (I);
         end loop;
      end if;
      if Base.Tuples.Tuple_Size /= null then
         for I in Base.Tuples.Tuple_Size'Range loop
            Base.Tuples.Tuple_Size (I) := Source.Tuples.Tuple_Size (I);
         end loop;
      end if;
      if Base.Tuples.Tuple_Objtype /= null then
         for I in Base.Tuples.Tuple_Objtype'Range loop
            Base.Tuples.Tuple_Objtype (I) := Source.Tuples.Tuple_Objtype (I);
         end loop;
      end if;
      if Base.Tuples.Tuple_Objid /= null then
         for I in Base.Tuples.Tuple_Objid'Range loop
            Base.Tuples.Tuple_Objid (I) := Source.Tuples.Tuple_Objid (I);
         end loop;
      end if;
      if Base.Tuples.Tuple_Objprm /= null then
         for I in Base.Tuples.Tuple_Objprm'Range loop
            Base.Tuples.Tuple_Objprm (I) := Source.Tuples.Tuple_Objprm (I);
         end loop;
      end if;
      if Base.Keys.Key_Time /= null then
         for I in Base.Keys.Key_Time'Range loop
            Base.Keys.Key_Time (I) := Source.Keys.Key_Time (I);
         end loop;
      end if;
      if Base.Keys.Key_Qpos /= null then
         for I in Base.Keys.Key_Qpos'Range loop
            Base.Keys.Key_Qpos (I) := Source.Keys.Key_Qpos (I);
         end loop;
      end if;
      if Base.Keys.Key_Qvel /= null then
         for I in Base.Keys.Key_Qvel'Range loop
            Base.Keys.Key_Qvel (I) := Source.Keys.Key_Qvel (I);
         end loop;
      end if;
      if Base.Keys.Key_Act /= null then
         for I in Base.Keys.Key_Act'Range loop
            Base.Keys.Key_Act (I) := Source.Keys.Key_Act (I);
         end loop;
      end if;
      if Base.Keys.Key_Mpos /= null then
         for I in Base.Keys.Key_Mpos'Range loop
            Base.Keys.Key_Mpos (I) := Source.Keys.Key_Mpos (I);
         end loop;
      end if;
      if Base.Keys.Key_Mquat /= null then
         for I in Base.Keys.Key_Mquat'Range loop
            Base.Keys.Key_Mquat (I) := Source.Keys.Key_Mquat (I);
         end loop;
      end if;
      if Base.Keys.Key_Ctrl /= null then
         for I in Base.Keys.Key_Ctrl'Range loop
            Base.Keys.Key_Ctrl (I) := Source.Keys.Key_Ctrl (I);
         end loop;
      end if;
      if Base.Names.Name_Bodyadr /= null then
         for I in Base.Names.Name_Bodyadr'Range loop
            Base.Names.Name_Bodyadr (I) := Source.Names.Name_Bodyadr (I);
         end loop;
      end if;
      if Base.Names.Name_Jntadr /= null then
         for I in Base.Names.Name_Jntadr'Range loop
            Base.Names.Name_Jntadr (I) := Source.Names.Name_Jntadr (I);
         end loop;
      end if;
      if Base.Names.Name_Geomadr /= null then
         for I in Base.Names.Name_Geomadr'Range loop
            Base.Names.Name_Geomadr (I) := Source.Names.Name_Geomadr (I);
         end loop;
      end if;
      if Base.Names.Name_Siteadr /= null then
         for I in Base.Names.Name_Siteadr'Range loop
            Base.Names.Name_Siteadr (I) := Source.Names.Name_Siteadr (I);
         end loop;
      end if;
      if Base.Names.Name_Camadr /= null then
         for I in Base.Names.Name_Camadr'Range loop
            Base.Names.Name_Camadr (I) := Source.Names.Name_Camadr (I);
         end loop;
      end if;
      if Base.Names.Name_Lightadr /= null then
         for I in Base.Names.Name_Lightadr'Range loop
            Base.Names.Name_Lightadr (I) := Source.Names.Name_Lightadr (I);
         end loop;
      end if;
      if Base.Names.Name_Flexadr /= null then
         for I in Base.Names.Name_Flexadr'Range loop
            Base.Names.Name_Flexadr (I) := Source.Names.Name_Flexadr (I);
         end loop;
      end if;
      if Base.Names.Name_Meshadr /= null then
         for I in Base.Names.Name_Meshadr'Range loop
            Base.Names.Name_Meshadr (I) := Source.Names.Name_Meshadr (I);
         end loop;
      end if;
      if Base.Names.Name_Skinadr /= null then
         for I in Base.Names.Name_Skinadr'Range loop
            Base.Names.Name_Skinadr (I) := Source.Names.Name_Skinadr (I);
         end loop;
      end if;
      if Base.Names.Name_Hfieldadr /= null then
         for I in Base.Names.Name_Hfieldadr'Range loop
            Base.Names.Name_Hfieldadr (I) := Source.Names.Name_Hfieldadr (I);
         end loop;
      end if;
      if Base.Names.Name_Texadr /= null then
         for I in Base.Names.Name_Texadr'Range loop
            Base.Names.Name_Texadr (I) := Source.Names.Name_Texadr (I);
         end loop;
      end if;
      if Base.Names.Name_Matadr /= null then
         for I in Base.Names.Name_Matadr'Range loop
            Base.Names.Name_Matadr (I) := Source.Names.Name_Matadr (I);
         end loop;
      end if;
      if Base.Names.Name_Pairadr /= null then
         for I in Base.Names.Name_Pairadr'Range loop
            Base.Names.Name_Pairadr (I) := Source.Names.Name_Pairadr (I);
         end loop;
      end if;
      if Base.Names.Name_Excludeadr /= null then
         for I in Base.Names.Name_Excludeadr'Range loop
            Base.Names.Name_Excludeadr (I) := Source.Names.Name_Excludeadr (I);
         end loop;
      end if;
      if Base.Names.Name_Eqadr /= null then
         for I in Base.Names.Name_Eqadr'Range loop
            Base.Names.Name_Eqadr (I) := Source.Names.Name_Eqadr (I);
         end loop;
      end if;
      if Base.Names.Name_Tendonadr /= null then
         for I in Base.Names.Name_Tendonadr'Range loop
            Base.Names.Name_Tendonadr (I) := Source.Names.Name_Tendonadr (I);
         end loop;
      end if;
      if Base.Names.Name_Actuatoradr /= null then
         for I in Base.Names.Name_Actuatoradr'Range loop
            Base.Names.Name_Actuatoradr (I) := Source.Names.Name_Actuatoradr (I);
         end loop;
      end if;
      if Base.Names.Name_Sensoradr /= null then
         for I in Base.Names.Name_Sensoradr'Range loop
            Base.Names.Name_Sensoradr (I) := Source.Names.Name_Sensoradr (I);
         end loop;
      end if;
      if Base.Names.Name_Numericadr /= null then
         for I in Base.Names.Name_Numericadr'Range loop
            Base.Names.Name_Numericadr (I) := Source.Names.Name_Numericadr (I);
         end loop;
      end if;
      if Base.Names.Name_Textadr /= null then
         for I in Base.Names.Name_Textadr'Range loop
            Base.Names.Name_Textadr (I) := Source.Names.Name_Textadr (I);
         end loop;
      end if;
      if Base.Names.Name_Tupleadr /= null then
         for I in Base.Names.Name_Tupleadr'Range loop
            Base.Names.Name_Tupleadr (I) := Source.Names.Name_Tupleadr (I);
         end loop;
      end if;
      if Base.Names.Name_Keyadr /= null then
         for I in Base.Names.Name_Keyadr'Range loop
            Base.Names.Name_Keyadr (I) := Source.Names.Name_Keyadr (I);
         end loop;
      end if;
      if Base.Names.Name_Pluginadr /= null then
         for I in Base.Names.Name_Pluginadr'Range loop
            Base.Names.Name_Pluginadr (I) := Source.Names.Name_Pluginadr (I);
         end loop;
      end if;
      if Base.Names.Names /= null then
         for I in Base.Names.Names'Range loop
            Base.Names.Names (I) := Source.Names.Names (I);
         end loop;
      end if;
      if Base.Names.Names_Map /= null then
         for I in Base.Names.Names_Map'Range loop
            Base.Names.Names_Map (I) := Source.Names.Names_Map (I);
         end loop;
      end if;
      if Base.Names.Paths /= null then
         for I in Base.Names.Paths'Range loop
            Base.Names.Paths (I) := Source.Names.Paths (I);
         end loop;
      end if;
      if Base.Sparse.B_Rownnz /= null then
         for I in Base.Sparse.B_Rownnz'Range loop
            Base.Sparse.B_Rownnz (I) := Source.Sparse.B_Rownnz (I);
         end loop;
      end if;
      if Base.Sparse.B_Rowadr /= null then
         for I in Base.Sparse.B_Rowadr'Range loop
            Base.Sparse.B_Rowadr (I) := Source.Sparse.B_Rowadr (I);
         end loop;
      end if;
      if Base.Sparse.B_Colind /= null then
         for I in Base.Sparse.B_Colind'Range loop
            Base.Sparse.B_Colind (I) := Source.Sparse.B_Colind (I);
         end loop;
      end if;
      if Base.Sparse.M_Rownnz /= null then
         for I in Base.Sparse.M_Rownnz'Range loop
            Base.Sparse.M_Rownnz (I) := Source.Sparse.M_Rownnz (I);
         end loop;
      end if;
      if Base.Sparse.M_Rowadr /= null then
         for I in Base.Sparse.M_Rowadr'Range loop
            Base.Sparse.M_Rowadr (I) := Source.Sparse.M_Rowadr (I);
         end loop;
      end if;
      if Base.Sparse.M_Colind /= null then
         for I in Base.Sparse.M_Colind'Range loop
            Base.Sparse.M_Colind (I) := Source.Sparse.M_Colind (I);
         end loop;
      end if;
      if Base.Sparse.MapM2M /= null then
         for I in Base.Sparse.MapM2M'Range loop
            Base.Sparse.MapM2M (I) := Source.Sparse.MapM2M (I);
         end loop;
      end if;
      if Base.Sparse.D_Rownnz /= null then
         for I in Base.Sparse.D_Rownnz'Range loop
            Base.Sparse.D_Rownnz (I) := Source.Sparse.D_Rownnz (I);
         end loop;
      end if;
      if Base.Sparse.D_Rowadr /= null then
         for I in Base.Sparse.D_Rowadr'Range loop
            Base.Sparse.D_Rowadr (I) := Source.Sparse.D_Rowadr (I);
         end loop;
      end if;
      if Base.Sparse.D_Diag /= null then
         for I in Base.Sparse.D_Diag'Range loop
            Base.Sparse.D_Diag (I) := Source.Sparse.D_Diag (I);
         end loop;
      end if;
      if Base.Sparse.D_Colind /= null then
         for I in Base.Sparse.D_Colind'Range loop
            Base.Sparse.D_Colind (I) := Source.Sparse.D_Colind (I);
         end loop;
      end if;
      if Base.Sparse.MapM2D /= null then
         for I in Base.Sparse.MapM2D'Range loop
            Base.Sparse.MapM2D (I) := Source.Sparse.MapM2D (I);
         end loop;
      end if;
      if Base.Sparse.MapD2M /= null then
         for I in Base.Sparse.MapD2M'Range loop
            Base.Sparse.MapD2M (I) := Source.Sparse.MapD2M (I);
         end loop;
      end if;
      Base.Bodies.Body_Plugin.all := [others => -1];
      Base.Geoms.Geom_Plugin.all := [others => -1];
      Base.Actuators.Actuator_Plugin.all := [others => -1];
      Base.Sensors.Sensor_Plugin.all := [others => -1];
      for I in 0 .. Source.S.Nactuator - 1 loop
         if Source.Actuators.Actuator_Plugin (I) >= 0 then
            Base.Actuators.Actuator_Gaintype (I) := 0;
            Base.Actuators.Actuator_Biastype (I) := 0;
            Base.Actuators.Actuator_Gainprm (10 * I) := 0.0;
            Base.Actuators.Actuator_Dyntype (I) := (if Source.Actuators.Actuator_Actnum (I) = 0 then 0 else 1);
         end if;
      end loop;
      for I in 0 .. Source.S.Nsensor - 1 loop
         if Source.Sensors.Sensor_Type (I) = 47 then Base.Sensors.Sensor_Type (I) := 48; end if;
      end loop;
   end Build;
end MJ.Plugin_Model_Copy;
