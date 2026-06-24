package idv.cjcat.stardustextended.initializers
{

public interface InitializerCollector
{

    function addInitializer(initializer : Initializer) : void;

    function removeInitializer(initializer : Initializer) : void;

    function clearInitializers() : void;
}
}