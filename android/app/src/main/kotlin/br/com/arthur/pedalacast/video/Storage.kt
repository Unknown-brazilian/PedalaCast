package br.com.arthur.pedalacast.video

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Environment
import android.os.ParcelFileDescriptor
import android.provider.MediaStore
import java.io.OutputStream

/** Salva em Movies/PedalaCast (vídeo) e Documents/PedalaCast (GPX/JSON) via MediaStore. */
object Storage {
    class Pending(val uri: Uri, val pfd: ParcelFileDescriptor)

    fun createVideo(ctx: Context, baseName: String): Pending {
        val v = ContentValues().apply {
            put(MediaStore.Video.Media.DISPLAY_NAME, "$baseName.mp4")
            put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
            put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/PedalaCast")
            put(MediaStore.Video.Media.IS_PENDING, 1)
        }
        val uri = ctx.contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, v)
            ?: error("Não foi possível criar o arquivo de vídeo")
        val pfd = ctx.contentResolver.openFileDescriptor(uri, "rw") ?: error("Não foi possível abrir o arquivo")
        return Pending(uri, pfd)
    }

    fun finishVideo(ctx: Context, uri: Uri) {
        val v = ContentValues().apply { put(MediaStore.Video.Media.IS_PENDING, 0) }
        ctx.contentResolver.update(uri, v, null, null)
    }

    fun deleteQuietly(ctx: Context, uri: Uri) {
        runCatching { ctx.contentResolver.delete(uri, null, null) }
    }

    fun createDoc(ctx: Context, fileName: String, mime: String): Pair<Uri, OutputStream> {
        val v = ContentValues().apply {
            put(MediaStore.Files.FileColumns.DISPLAY_NAME, fileName)
            put(MediaStore.Files.FileColumns.MIME_TYPE, mime)
            put(MediaStore.Files.FileColumns.RELATIVE_PATH, Environment.DIRECTORY_DOCUMENTS + "/PedalaCast")
        }
        val uri = ctx.contentResolver.insert(MediaStore.Files.getContentUri("external"), v)
            ?: error("Não foi possível criar $fileName")
        return uri to (ctx.contentResolver.openOutputStream(uri) ?: error("Não foi possível abrir $fileName"))
    }

    fun createImage(ctx: Context, fileName: String): Pair<Uri, OutputStream> {
        val v = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/PedalaCast")
        }
        val uri = ctx.contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, v)
            ?: error("Não foi possível criar a imagem")
        return uri to (ctx.contentResolver.openOutputStream(uri) ?: error("Não foi possível abrir a imagem"))
    }

    fun list(ctx: Context): List<Map<String, Any?>> {
        val out = ArrayList<Map<String, Any?>>()
        val proj = arrayOf(
            MediaStore.Video.Media._ID, MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.SIZE, MediaStore.Video.Media.DURATION, MediaStore.Video.Media.DATE_ADDED,
        )
        ctx.contentResolver.query(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI, proj,
            "${MediaStore.Video.Media.RELATIVE_PATH} LIKE ?", arrayOf("%PedalaCast%"),
            "${MediaStore.Video.Media.DATE_ADDED} DESC",
        )?.use { c ->
            while (c.moveToNext()) {
                val id = c.getLong(0)
                out.add(
                    mapOf(
                        "uri" to ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id).toString(),
                        "name" to c.getString(1), "size" to c.getLong(2),
                        "durationMs" to c.getLong(3), "dateAdded" to c.getLong(4) * 1000,
                    )
                )
            }
        }
        return out
    }

    fun freeBytes(): Long {
        val st = android.os.StatFs(Environment.getExternalStorageDirectory().path)
        return st.availableBytes
    }
}
