# Creating a release

DCli uses the package [pub\_release](https://pub.dev/packages/pub\_release#-analysis-tab-) (written in DCli) to create releases.

Start by installing pub\_release.

```
pub global activate pub_release
```

Commit and push all of you code changes.

pub\_release performs the following tasks

* Incrementing the version no.
* formatting code
* generating release notes
* checking that all code is committed
* pushing the release
* git tagging the release with the new version no.
* publishing the the new release to pub.dev

Run pub\_release

```
cd dcli
pub_release
```

Answer the questions asked.

Job done.
