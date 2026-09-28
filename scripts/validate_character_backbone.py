from criterivox.runtime.characters.backbone.loader import load_character_registry,load_capability_registry,load_message_chips
from criterivox.runtime.characters.backbone.validator import validate_or_raise
from criterivox.runtime.characters.backbone.chips import validate_message_chips
def main():
    c=load_character_registry(); caps=load_capability_registry(); chips=load_message_chips()
    validate_or_raise(c,caps); validate_message_chips(chips)
    print(f"VALID: characters={len(c.characters)} capabilities={len(caps.capabilities)} chips={len(chips['chips'])}")
if __name__=="__main__":main()
