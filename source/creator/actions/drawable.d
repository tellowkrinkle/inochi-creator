/*
    Copyright © 2020,2022 Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
*/
module creator.actions.drawable;
import creator.core.actionstack;
import creator.actions;
import creator;
import inochi2d;
import std.format;
import i18n;

/**
    Action to add parameter to active puppet.
*/
class DrawableChangeAction : GroupAction, LazyBoundAction {
private:
    void copy(ref MeshData src, ref MeshData dst) {
        dst.vertices = src.vertices.dup;
        dst.uvs      = src.uvs.dup;
        dst.indices  = src.indices.dup;
        dst.origin   = src.origin;
    }
public:
    Drawable self;
    string name;

    MeshData mesh;
    bool     undoable;

    this(string name, Drawable self) {
        super();
        this.name = name;
        this.self = self;
        this.undoable = true;
        copy(self.getMesh(), mesh);
    }

    override
    void updateNewState() {
    }

    void addBinding(Parameter param, ParameterBinding binding) {
        addAction(new ParameterBindingRemoveAction(param, binding));
    }

    /**
        Rollback
    */
    override
    void rollback() {
        if (undoable) {
            MeshData tmpMesh;
            copy(self.getMesh(), tmpMesh);
            self.rebuffer(mesh);
            mesh = tmpMesh;
            undoable = false;
        }
        super.rollback();
    }

    /**
        Redo
    */
    override
    void redo() {
        if (!undoable) {
            MeshData tmpMesh;
            copy(self.getMesh(), tmpMesh);
            self.rebuffer(mesh);
            mesh = tmpMesh;
            undoable = true;
        }
        super.redo();
    }

    /**
        Describe the action
    */
    override
    string describe() {
        return _("Changed drawable mesh of %s").format(self.name);
    }

    /**
        Describe the action
    */
    override
    string describeUndo() {
        return _("Drawable %s was changed").format(self.name);
    }

    /**
        Gets name of this action
    */
    override
    string getName() {
        return this.stringof;
    }
    
    override bool merge(Action other) { return false; }
    override bool canMerge(Action other) { return false; }
}
