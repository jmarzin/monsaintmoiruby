#[macro_use]
extern crate helix;

ruby! {
    class GpxManage {
        def demande_secret() -> String {
            String::from("Entrez votre code secret")
        }
    }
}
