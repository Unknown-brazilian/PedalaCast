package br.com.arthur.pedalacast.video

import com.pedro.library.base.recording.RecordController
import com.pedro.library.util.AndroidMuxerRecordController
import java.io.FileDescriptor

/**
 * StreamBase.startRecord só aceita caminho de arquivo. Gravamos via MediaStore (scoped storage),
 * então este controlador delega ao AndroidMuxerRecordController usando o FileDescriptor.
 */
class FdRecordController(
    private val fd: FileDescriptor,
    private val inner: AndroidMuxerRecordController = AndroidMuxerRecordController(),
) : RecordController by inner {
    override fun startRecord(path: String, listener: RecordController.Listener?, tracks: RecordController.RecordTracks) {
        inner.startRecord(fd, listener, tracks)
    }
}
