//
//  Plane.swift
//  arkit-by-example
//
//  Converted to Swift by Tulio Troncoso on 6/15/17.
//  Created by md on 6/9/17
//  Copyright © 2017 ruanestudios. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    
    init(with anchor: ARPlaneAnchor, hidden: Bool) {
        super.init()
        
        self.anchor = anchor
        let width = CGFloat(anchor.extent.x)
        let length = CGFloat(anchor.extent.z)
        
        // Using a SCNBox and not SCNPlane to make it easy for the geometry we add to the
        // scene to interact with the plane.
        
        // For the physics engine to work properly give the plane some height so we get interactions
        // between the plane and the gometry we add to the scene
        let planeHeight = CGFloat(0.01)
        
        planeGeometry = SCNBox(width: width, height: planeHeight, length: length, chamferRadius: 0)
        
        // Instead of just visualizing the grid as a gray plane, we will render
        // it in some Tron style colours.
        let material = SCNMaterial()
        let image = UIImage(named: "tron_grid.png")
        material.diffuse.contents = image
        
        // Since we are using a cube, we only want to render the tron grid
        // on the top face, make the other sides transparent
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
        
        if (hidden) {
            planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
        } else {
            planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, material, transparentMaterial]
        }
        
        let planeNode = SCNNode(geometry: planeGeometry)
        
        // Since our plane has some height, move it down to be at the actual surface
        planeNode.position = SCNVector3Make(0, -Float(planeHeight) / 2, 0)
        
        // Give the plane a physics body so that items we add to the scene interact with it
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        
        setTextureScale()
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(anchor: ARPlaneAnchor) {
        // As the user moves around the extend and location of the plane
        // may be updated. We need to update our 3D geometry to match the
        // new parameters of the plane.
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.length = CGFloat(anchor.extent.z)
        
        // When the plane is first created it's center is 0,0,0 and the nodes
        // transform contains the translation parameters. As the plane is updated
        // the planes translation remains the same but it's center is updated so
        // we need to update the 3D geometry position
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        let node = childNodes.first!
        
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        setTextureScale()
    }
    
    func setTextureScale() {
        let width = Float(planeGeometry.width)
        let height = Float(planeGeometry.length)
        
        // As the width/height of the plane updates, we want our tron grid material to
        // cover the entire plane, repeating the texture over and over. Also if the
        // grid is less than 1 unit, we don't want to squash the texture to fit, so
        // scaling updates the texture co-ordinates to crop the texture in that case
        let material = planeGeometry.materials[4]
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1)
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
    }
    
    func hide() {
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
        planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
    }
}

